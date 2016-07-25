###
    Line object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents 2D line's in a purely geometric sense.
###

class BT2D.Line #implements BT2D.Geometry, BT2D.BinaryPartitioner

    constructor: (_p1, _p2, @_type = BT2D.Line.SEGMENT) ->
    
        if @_type != BT2D.Line.RAY
            @_p1 = _p1.clone()
            @_p2 = _p2.clone()
            @_offset = @_p2.clone().sub(@_p1)
            @_dir = @_offset.clone().normalize()
        else 
            @_p1 = _p1.clone()
            @_offset = _p2.clone().normalize()
            @_p2 = @_p1.clone().add(@_offset)
            @_dir = @_offset.clone().normalize()
        
        # Rotate the direction to get the normal direction.
        # Naturally it is still normalized.
        @_normal = @_dir.clone()
        temp = @_normal.x
        @_normal.x = -@_normal.y
        @_normal.y = temp
    
    # Returns the inversion of this object in the same type.
    getInvert: () ->
        if @_type != BT2D.Line.RAY
            return new BT2D.Line(@_p2, @_p1, @_type)
        else
            return new BT2D.Line(@_p2, @_offset.clone().multiplyScalar(-1), @_type)

    # Mode setting functions.
    makeUnbounded: () ->
        @_type = BT2D.Line.UNBOUNDED

    makeRay: () ->
        @_type = BT2D.Line.RAY

    makeSegment: () ->
        @_type = BT2D.Line.SEGMENT


    getNormal: () ->
        return @_normal.clone()

    getP1: () -> return @_p1.clone()
    getP2: () -> return @_p2.clone()

    getOrigin:    () -> return @_p1.clone()
    getDirection: () -> return @_offset.clone()# we use offset, so that segment intersection works.
    getType: () -> return @_type

    # Expects a Three.JS vector. It doesn't have to be normalized.
    # RETURNS the perfect specular direction reflection.
    # FIXME: Consider putting this in some common mathematics library instead.
    getPerfectSpecularReflectionDirection: (incoming_direction) ->
        
        normal = @_normal.clone()
        cosI = normal.dot(incoming_direction)
        # In a perfect specular reflection, only the component 
        # of the incoming direction perpendicular to the surface normal will be negated.
        perp_component = normal.multiplyScalar(2*cosI)
        output = incoming_direction.clone()
        output.sub(perp_component)

        return output


    getFrontNormal : (incoming_direction) ->
        
        output = @_normal.clone()

        if output.dot(incoming_direction) > 0
            output.multiplyScalar(-1)

        return output        

    
    # Populates the intersection result for any input segment, ray, or Unbounded line.
    # Overrides any existing results in the intersection object.
    intersectAny : (line, intersection) ->
        time = @_intersectRayTime(line)
        return false if (time == BT2D.Constants.NO_INTERSECTION)

        intersection.time = time
        return true

    #@Override Geometry.
    intersectRay : (ray, intersection, min_time) ->

        time = @_intersectRayTime(ray)

        return false if (time == BT2D.Constants.NO_INTERSECTION) #or time < min_time

        # Return false if this intersection is not minimal.
        if intersection.time != null and intersection.time < time
            return false
        
        intersection.time = time

        # Inform the caller that there was a valid, although perhaps not minimal and updating, intersection for this call.
        return true

    # Returns [result, left_frustrum, right_frustrum, BT2D.surface]
    # Note: Frustrums are BT2D.LightFrustrums.
    # @Overrides BT2D.Geometry
    # NOTE: we don't returns a surface here, because geometries know naught about surfaces.
    intersectFrustrum: (lightFrustrum, min_time1, min_time2) ->

        # prevent self intersections.
        # We need to explicitly do this, instead of handling it with the fudge factors, because we want to allow the proper transitioning
        # between geometries intersect each other at the same source point.
        # Hopefully the point with not be juggled infinitly between the two surfaces, because frustrum bound non-intersection checking should
        # weed out the bad cases.
        if lightFrustrum.source_geometry == @
            return [false, null, null, null]

        frustrum = lightFrustrum.frustrum

        # Extract relevant Binary Partitioners.
        bp_left  = frustrum.getLeftBP()
        bp_right = frustrum.getRightBP()
        ray1 = bp_left
        ray2 = bp_right

        # We can simplify the logic tests by sorting the points
        # with regards to the orientation of this frustrum.
        
        ###
        [pt_left, pt_right] = bp_left.orientPts(@_p1, @_p2)
        [pt_left2, pt_right2] = bp_right.orientPts(@_p1, @_p2)
        ###

        [pt_left, pt_right] = @_radiallyOrientPts(lightFrustrum, @_p1, @_p2)
        pt_left2 = pt_left
        pt_right2 = pt_right


        # Break this down into cases.

        # Compute the 4 classifications.
        # Classification_partitioner_pt
        # c_(frustrum bounding ray)_which oriented point on this line.
        c_l_l = bp_left.side_test(pt_left)
        c_l_r = bp_left.side_test(pt_right)
        c_r_l = bp_right.side_test(pt_left2)
        c_r_r = bp_right.side_test(pt_right2)

        bp_start = frustrum.getStartingBP()

        # This is the tricky part, the current scheme we are using to detect intersection is the folloring:
        # An intersection exists if one of the rays intersects this line or the rays enclose one of this line's end points.
        # FIXME: We will probaly have to come back and handle ray's, unbounded segments, etc at some point when the dust settles.
        intersection_exists = false

        # The way this test works is that we check to see if
        # a non trivial area is enclosed by the incoming frustum.
        # this is done through presise uses of strict and non strict in equality.
        # we check to see if the frustum non trivially encloses the left or right points on the line.
        # the left ray can be on the left point and the right ray can be on the right point,
        # but the right ray cannot be on the left point and the left ray cannot be on the right point, since that is a signal for no collision.
        
        if ((c_l_l >= BT2D.Constants.ON and # left point is on or to the right of the left ray.
           c_r_l   < BT2D.Constants.ON) or  # left point is strictly to the left of the right ray.
           (c_l_r  > BT2D.Constants.ON and  # right point is strictly to the right of the left ray.
           c_r_r   <= BT2D.Constants.ON))   # right point is on or to the left of the right ray.
            if bp_start == null or
               bp_start.side_test(pt_left) < BT2D.Constants.ON or
               bp_start.side_test(pt_right) < BT2D.Constants.ON
                intersection_exists = true
        
        
        ###
        intersection_exists = true

        
        # left point is on or to the right of the right ray.
        if c_r_l >= BT2D.Constants.ON
            intersection_exists = false

        if c_l_r <= BT2D.Constants.ON
            intersection_exists = false

        # if both points are on the non frustrum side of the flat starting front of the frustrum,
        # then there can be no intersection.
        if bp_start != null and
           bp_start.side_test(pt_left) >= BT2D.Constants.ON and
           bp_start.side_test(pt_right) >= BT2D.Constants.ON
            intersection_exists = false
        ###

        # Rule out those cases where neither ray intersects the partitioning space of this line.
        # This gets rid of funky slants.

        intersection_left  = new BT2D.Intersection()
        intersection_right = new BT2D.Intersection()

        bp_left.intersectAny(@, intersection_left)
        bp_right.intersectAny(@, intersection_right)

        t_left  = intersection_left.time
        t_right = intersection_right.time

        if @_p1 != pt_left
            if t_left != BT2D.Constants.NO_INTERSECTION
                t_left = 1.0 - t_left

        if @_p1 != pt_left2
            if t_right != BT2D.Constants.NO_INTERSECTION
                t_right = 1.0 - t_right

        # intersection predicates.
        # The intersection points must enclose a non-trivial area.
        # We dont' actually care what the time is or its orientation, but rather that it is bounded.
        i_left  = (t_left != BT2D.Constants.NO_INTERSECTION and t_left  < 1.0 - BT2D.Constants.EPSILON)
        i_right = (t_right!= BT2D.Constants.NO_INTERSECTION and t_right > 0.0 + BT2D.Constants.EPSILON)

        if (i_left or i_right)
            intersection_exists = true

        # now check for the frustrum entirely containing the line.
        ###
        t_left  = @ray_partition_intersection_time(bp_left)
        t_right = @ray_partition_intersection_time(bp_right)

        if @_p1 != pt_left
            if t_left != BT2D.Constants.NO_INTERSECTION
                t_left2 = 1.0 - t_left

            if t_right != BT2D.Constants.NO_INTERSECTION
                t_right2 = 1.0 - t_right

        if @_p1 != pt_left2
            if t_left != BT2D.Constants.NO_INTERSECTION
                t_left3 = 1.0 - t_left

            if t_right != BT2D.Constants.NO_INTERSECTION
                t_right3 = 1.0 - t_right

        i_left_of_line = 

        if t_left == BT2D.Constants.NO_INTERSECTION and 
        ###


        # Detect non-intersections.
        if not intersection_exists
            return [false, null, null, null]

        # From here on out an intersection does exist.

        intersection1 = new BT2D.Intersection()
        intersection2 = new BT2D.Intersection()

        # Frustrum is entirely within the line.
        if i_left and i_right
            
            @intersectRay(ray1, intersection1, min_time1)
            @intersectRay(ray2, intersection2, min_time2)

            end1 = intersection1.computePosition(ray1)
            end2 = intersection2.computePosition(ray2)

            lightFrustrum.complete(end1, end2, intersection1.time, intersection2.time)

            return [true, null, null, null]

        # The frustrum must contain a left split or right split.

        # This is the starting plane that the frustrum comes from.
        # null if mono focused.
        bp_start = frustrum.getStartingBP()

        focus = frustrum.getFocusPoint()

        left_frustrum  = null
        right_frustrum = null

        # Handle left splits.
        if not i_left #c_l_l == BT2D.Constants.RIGHT
            # If a split occurs, then we will use the original left end point from THIS line
            # as the end point for the middle frustrum.

            # We need to use the orientation of points with regards to the right edge.
            # FIXME: Refactor this idea for non acute frustrums more generally in this function.
            left_frustrum = lightFrustrum.splitLeft(pt_left2)
            pt_left = pt_left2
            
        else
            # Otherwise, there must be an intersection and we calculate it and set it to be the left pt.
            @intersectRay(ray1, intersection1, min_time1)
            pt_left = intersection1.computePosition(ray1)

        # Handle right splits.
        if not i_right #c_r_r == BT2D.Constants.LEFT

            # FIXME: For some reason, I can run two google chrome stack frame and pt_right ends up being a different result each time.

            right_frustrum = lightFrustrum.splitRight(pt_right)
        else
            @intersectRay(ray2, intersection2, min_time2)
            pt_right = intersection2.computePosition(ray2)

        # Finalize the input light frustrum by completing it.
        dist1 = pt_left.clone().sub(frustrum.getStart1()).length()
        dist2 = pt_right.clone().sub(frustrum.getStart2()).length()

        # This only works, if we have computed the correct left and right points.
        lightFrustrum.complete(pt_left, pt_right, dist1, dist2)

        console.log(lightFrustrum);

        return [true, left_frustrum, right_frustrum, null]



    # Finds and returns the intersection time if it exists.
    # ray can be any BT2D.ray or BT2D.Line object be it a ray, segment.
    # FIXME: I am thinking of removing BT2D.ray's all together someday.
    # returns BT2D.Constants.NO_INTERSECTION otherwise.
    _intersectRayTime : (ray) ->
        
        # Transcribed from here: github.com/Bryce-Summers/ofxScribbleSegmenter/blob/master/src/Line.cpp end of line.

        ###
        First of all, here is the intersection math.
        u = ((bs.y - as.y) * bd.x - (bs.x - as.x) * bd.y) / (bd.x * ad.y - bd.y * ad.x)
        v = ((bs.y - as.y) * ad.x - (bs.x - as.x) * ad.y) / (bd.x * ad.y - bd.y * ad.x)
        Factoring out the common terms, this comes to:
        dx = bs.x - as.x
        dy = bs.y - as.y
        det = bd.x * ad.y - bd.y * ad.x
        u = (dy * bd.x - dx * bd.y) / det
        v = (dy * ad.x - dx * ad.y) / det
        ###

        # Extract the relevant points.
        as  = @_p1
        bs  = ray.getOrigin()
        ad  = @_offset
        bd  = ray.getDirection()

        dx  = bs.x - as.x
        dy  = bs.y - as.y
        det = bd.x * ad.y - bd.y * ad.x

        # For our intents and purposes a ray doesn't intersect a collinear line segment.
        return BT2D.Constants.NO_INTERSECTION if Math.abs(det) < .0001

        u = (dy * bd.x - dx * bd.y) / det;
        v = (dy * ad.x - dx * ad.y) / det;

        #console.log("u = " + u + ", " + "v = " + v)

        # The intersection is at time coordinates u and v.
        # Note: Time is relative to the offsets, so p1 = time 0 and p2 is time 1.
        # u is the time coordinate for this line.
        # v is the time coordinate for the ray, it is in the ray's normalized space and
        # therefore give a consistent time for comparing ray intersection distances.

        # culling based on this line type.

        # There is no intersection if the ray doesn't intersect the bounded portion, if this line is bounded.
        return BT2D.Constants.NO_INTERSECTION if @_type != BT2D.Line.UNBOUNDED and u < -BT2D.Constants.EPSILON
        return BT2D.Constants.NO_INTERSECTION if @_type == BT2D.Line.SEGMENT and u > 1 + BT2D.Constants.EPSILON

        # culling based on the input line type.
        ot = ray.getType()

        # There is no intersection if the ray is pointed the wrong direction or doesn't go anywhere.
        # We use 2 here, to allow rays to intersect their origin, even if they have been offset by an epsilon fudge factor.
        return BT2D.Constants.NO_INTERSECTION if ot != BT2D.Line.UNBOUNDED and v < -BT2D.Constants.EPSILON*1.5
        return BT2D.Constants.NO_INTERSECTION if ot == BT2D.Line.SEGMENT and v > 1 + BT2D.Constants.EPSILON*1.5

        # Return the time of intersection.
        return v

    # Classify the incoming THREE.Vector3 point and return one of the following:
    # Returns BT2D.LEFT on one side of the line.
    # Returns BT2D.ON if the point is on the line.
    # Returns BT2D.RIGHT if the point is on the other side of the line.
    #@ Override BT2D.BinaryPartitioner
    # A line side test for any of the three line like structures.
    side_test: (pt) ->

        val = @side_test_scalar(pt)

        if Math.abs(val) < BT2D.Constants.EPSILON
            return BT2D.Constants.ON

        return BT2D.Constants.LEFT  if val < 0
        return BT2D.Constants.RIGHT if val > 0
        #return BT2D.Constants.ON
        console.log("Impossible to get here!")

    # Returns < 0 if on the 'left' side of the line.
    # Returns = 0 if on the line.
    # Returns > 0 if on the 'right' side of the line.
    side_test_scalar: (c) ->
        return ((@_p1.x - @_p2.x)*(c.y - @_p2.y) - (@_p1.y - @_p2.y)*(c.x - @_p2.x))

    # Returns a representative point 'pt' such that @side_test(pt) = BT2D.ON
    #@ Override BT2D.BinaryPartitioner
    representative_point: () ->
        return _p1.clone()

    # populates the intersection between the ray and this Binary partitioner.
    # if the binary partitioner was made from a line segment, then it will return the intersection on the line containing the segment,
    # even if the intersection is not inside of the segment.
    # If the binary partitioner is of non-trivial width, it should return the intersection on the halfplane not containing the origin of the incoming ray.
    # returns a positive time if a valid intersection exists, otherwise returns BT2D.Constants.NO_INTERSECTION, which is guranteed to be negative.
    #@ Override BT2D.BinaryPartitioner
    ray_partition_intersection_time: (ray) ->
        saveType = @_type
        @makeUnbounded()
        time = @_intersectRayTime(ray)
        @_type = saveType
        return time

    getPosition: (time) ->
        offset = @getDirection()
        offset.multiplyScalar(time)
        location = @getOrigin()
        location.add(offset)
        return location

    # Splits this geometry along the given binary space partitioner.
    # Returns two geometries that are on either side of the input binary partitioner.
    # [left, right]
    # return [null, null, null] if the partitioner doesn't intersect this surface.
    #@override BT2D.BinaryPartitioner
    split: (bp) ->
        
        time  = bp.ray_partition_intersection_time(@)
        side1 = bp.side_test(@_p1) # We use the discrete side test so that lines close to being collinear get lumped together.
        side2 = bp.side_test(@_p2)


        # No intersection between unbounded implies this line is parrallel to the space partitioner.
        if time == BT2D.Constants.NO_INTERSECTION or (side1 == side2 and @_type == BT2D.Line.SEGMENT)
            return [@, null, null] if side1 < 0
            return [null, @, null] if side1 == 0
            return [null, null, @] if side1 > 0

        pt_split = @getPosition(time)
        
        switch @_type
            when BT2D.Line.UNBOUNDED
                out1 = new BT2D.Line(pt_split, @_dir.clone().multiplyScalar(-1), BT2D.Line.RAY)
                out2 = new BT2D.Line(pt_split, @_dir, BT2D.Line.RAY)
                break
            when BT2D.Line.RAY
                out1 = new BT2D.Line(@_p1, pt_split,  BT2D.Line.SEGMENT)
                out2 = new BT2D.Line(pt_split, @_dir, BT2D.Line.RAY)
                break
            when BT2D.Line.SEGMENT
                out1 = new BT2D.Line(@_p1, pt_split,  BT2D.Line.SEGMENT)
                out2 = new BT2D.Line(pt_split, @_p2, BT2D.Line.SEGMENT)
                break     

        # NOTE: For lines, we ignore the on point and just output left and right geometries.
        return [out1, null, out2] if side1 < 0
        return [out2, null, out1]

    #@override BT2D.Geometry
    orientPts: (pt1, pt2) ->
        
        side1 = @side_test_scalar(pt1)
        side2 = @side_test_scalar(pt2)

        return [pt1, pt2] if side1 < side2
        return [pt2, pt1]

    _radiallyOrientPts: (lightFrustrum, pt1, pt2) ->
        orientation_ray = lightFrustrum.getSplitRay(pt1)
        classification = orientation_ray.side_test(pt2)

        return [pt1, pt2] if classification >= BT2D.Constants.ON
        return [pt2, pt1]

# Types of lines.
BT2D.Line.SEGMENT = 0   # Both end points define ends for the line.
BT2D.Line.UNBOUNDED = 1 # Specifies any linear combination of the two input points.
BT2D.Line.RAY = 2       # The line that starts at p1 and travels in the direction of p2.