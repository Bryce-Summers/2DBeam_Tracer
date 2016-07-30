###
    Frustrum object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents the geometry of individual frustrums,
     - Along with associated starting and ending data and spectrum data.
     
     
    Representation:
     - The Frustrum is represented by 4 2D vector locations, 
       represented by 2 pairs of starting and ending points.
     - the ray start1 -> end1 is represented guranteed to be to the left ( counter-clockwise ) of start2 -> end2
     
     The frustrum is said to be complete then it has all 4 points, but imcomplete it it only has the near points defined.


    Frustrums have a notion of completeness, mono vs multiple directionality, and having a focus. Interpolation is linear for now...

###
class BT2D.Frustrum

    # The two directions are only used temporarily for use in the casting completion proccess.
    # the direction vectors may be modified externally for making proper directions.
    constructor: (_start1, _start2, _dir1, _dir2) ->

        @original_start1 = _start1
        @original_start2 = _start2

        @_dir1 = _dir1.clone()
        @_dir2 = _dir2.clone()

        @_dir1.normalize()
        @_dir2.normalize()


        # We 'fudge' the starting positions of the frustrums to avoid intersections with this surface.
        @_start1 = _start1.clone()
        @_start2 = _start2.clone()
    
        # At the start, we do not yet have proper ending points,
        # we only have directions.
        @_end1 = null
        @_end2 = null

        @mono_focused = (_start1 == _start2) or (@_start1.clone().sub(@_start2).length() < BT2D.Constants.EPSILON)

        @checkDegenerate()
        @checkBounds(@_start1, @_start2)
        @validateOrientation()

    checkDegenerate: () ->
        # FIXME: Remove this check in the future to speed up performance.

        if not @mono_focused and @_start1.clone().sub(@_start2).length() < .001
            console.log("ERROR: this frustum has been set to a trivial area.");
            debugger;

        if @_dir1.length() > 2
            console.log("ERROR: improper direction  passed to frustrum!");
            debugger;

        if @_dir2.length() > 2
            console.log("ERROR: improper direction  passed to frustrum!");
            debugger;

    checkBounds: (p1, p2) ->
        if p1.x < -50.0 - BT2D.Constants.EPSILON
            debugger

        if p1.x > 50.0 + BT2D.Constants.EPSILON
            debugger

        if p2.y < -50.0 - BT2D.Constants.EPSILON
            debugger

        if p2.y > 50.0 + BT2D.Constants.EPSILON
            debugger
       
    # Make sure that the orientation of the two rays is correct.
    validateOrientation: () ->
        # TODO.

        ray1 = @getLeftRay()
        bp_1 = @getLeftBP()

        ray2 = @getRightRay()
        bp_2 = @getRightBP()

        pt1 = ray1.getPosition(1)
        pt2 = ray2.getPosition(1)

        classification1 = bp_2.side_test(pt1)
        classification2 = bp_1.side_test(pt2)

        if classification1 > BT2D.Constants.ON
            console.log("ERROR: Validation failed")

        if classification2 < BT2D.Constants.ON
            console.log("ERROR: Validation failed")

        return        

    # THREE.vector3's
    complete: (end1, end2) ->
        @_end1 = end1.clone()
        @_end2 = end2.clone()
        
    setLeftRay: (ray) ->
        @_start1 = ray.getOrigin()
        @_dir1   = ray.getDirection()
        @_dir1.normalize()
        @checkDegenerate()

    setRightRay: (ray) ->
        @_start2 = ray.getOrigin()
        @_dir2   = ray.getDirection()
        @_dir2.normalize()
        @checkDegenerate()

    getDir1: () ->
        return @_dir1.clone()

    getDir2: () ->
        return @_dir2.clone()

    getStart1: () -> @_start1.clone()
    getStart2: () -> @_start2.clone()
    
    getEnd1: () -> @_end1.clone()
    getEnd2: () -> @_end2.clone()
        
    getLeftBP: () ->
        return new BT2D.Line(@_start1, @_dir1, BT2D.Line.RAY)

    getRightBP: () ->
        return new BT2D.Line(@_start2, @_dir2, BT2D.Line.RAY)

    getLeftRay: () ->
        return new BT2D.Line(@_start1, @_dir1, BT2D.Line.RAY)

    getRightRay: () ->
        return new BT2D.Line(@_start2, @_dir2, BT2D.Line.RAY)

    # The Unbounded line whose left face is included and right face is excluded.
    # Returns null if this frustrum is mono_focused, because in that case the starting partitioner 
    # is not-well defined and yields no further information.
    getStartingBP: () ->
        return null if @mono_focused
        return new BT2D.Line(@_start1, @_start2, BT2D.Line.UNBOUNDED)

    # All frustrums have a focus point defined by the intersection of the two rays.
    # Any frustrum that does not have a focus point is said to be mono-directional and will return null.
    getFocusPoint: () ->

        # Return one of the starting points if they are the same.
        # FIXME: make sure this equality check is proper.
        return @_start1.clone() if @mono_focused

        left  = @getLeftRay()
        left.makeUnbounded()
        right = @getRightRay().getInvert()
        left.makeUnbounded()

        intersection = new BT2D.Intersection()
        
        # Specify singular originating frustrums.
        return null if not left.intersectAny(right, intersection)

        return intersection.computePosition(right)

    # Injests a point and outputs the appropiate sub ray from
    # this frustrum that contains the given pt.
    # [ray, percentage] returns the ray along with the percentage value that indicates its relationship within the set of all rays in this frustrum.
    getSplitRay: (pt) ->

        bp_start = @getStartingBP()
        focus = @getFocusPoint()

        # Handle mono-directional frustrum.
        if focus == null
            
            mono_direction = @getLeftRay().getDirection()
            back_dir = mono_direction.clone().multiplyScalar(-1)
            back_split_ray = new BT2D.Line(pt, back_dir, BT2D.Line.RAY)

            # ASSUMPTION bp_start needs to be defined,
            # because otherwise the frustrum would be of trivial area (a ray) and we don't support them,
            # because they don't contribute illuminated areas.
            percentage = back_split_ray.ray_partition_intersection_time(bp_start)

            # clamp time.
            percentage = Math.min(1.0, Math.max(percentage, 0.0))

            split_start = bp_start.getPosition(percentage)

            split_ray = new BT2D.Line(split_start, mono_direction, BT2D.Line.RAY)
            return [split_ray, percentage]

        # Start with the ray from the focus to the pt.
        split_ray = new BT2D.Line(focus, pt)
        # We convert it to a ray after construction to allow for us to create it with points,
        # rather than a point and a direction vector.
        split_ray.makeRay()

        # Non-mono focused.
        if bp_start != null
            
            # We first compute the point along te starting edge that lies along the ray from the focus to the point.
            time  = split_ray.ray_partition_intersection_time(bp_start)
            split_start = split_ray.getPosition(time)

            # We can then compute the percentage along the start edge via a comparison of distances.
            # FIXME: reword this, since I am tired right now.
            dist1 = split_start.clone().sub(@_start1)
            dist2 = split_start.clone().sub(@_start2)
            percentage = dist1 / (dist1 + dist2)

            split_ray = new BT2D.Line(split_start, pt)
            split_ray.makeRay()
        else

            # We linearly interpolate based on the line side test quantities.
            # We do this in the point source case here, because we might want to
            # make frustrums that emmit different spectrums in different directions.
            per_left  =  @getLeftBP().side_test_scalar(pt)
            per_right = -@getRightBP().side_test_scalar(pt)
            percentage = per_left / (per_left + per_right)

            # clamp time.
            percentage = Math.min(1.0, Math.max(percentage, 0.0))

        return [split_ray, percentage]