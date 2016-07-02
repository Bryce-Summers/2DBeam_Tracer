###
    Line object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents 2D line's in a purely geometric sense.
###

class BT2D.Line #implements BT2D.Geometry, BT2D.BinaryPartitioner

    # Types of lines.
    SEGMENT = 0   # Both end points define ends for the line.
    UNBOUNDED = 1 # Specifies any linear combination of the two input points.
    RAY = 2       # The line that starts at p1 and travels in the direction of p2.

    constructor: (_p1, _p2, @_type) ->
    
        # Default mode is line semgnet
        @_type = SEGMENT if !(_type?) # FIXME: Double check this syntax.

        if @_type != BT2D.Line.RAY
            @_p1 = _p1.clone()
            @_p2 = _p2.clone()
            @_offset = @_p2.clone().sub(@_p1)
            @_dir = @_offset.clone().normalize()

        else 
            @_p1 = _p1.clone()
            @_offset = @_p2.clone().normalize()
            @_p2 = @_p1.clone().add(_offset)
            @_dir = @_offset.clone()
        
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
        @_type = UNBOUNDED

    makeRay: () ->
        @_type = RAY

    makeSegment: () ->
        @_type = SEGMENT


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
        normal = @_normal
        normal_proj_mag = incoming_direction.dot(normal)
        normal_proj = normal.clone().multiplyScalar(normal_proj_mag)

        if normal_proj_mag < 0
            normal_proj.multiplyScalar(-1)

        return incoming_direction.clone().sub(normal_proj.multiplyScalar(2))
    
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

        return false if (time == BT2D.Constants.NO_INTERSECTION) or time < min_time

        # Update the intersection.
        intersection.time = time if time > min_time && (intersection.time == null || intersection.time > time)

        # Inform the caller that there was a valid, although perhaps not minimal and updating, intersection for this call.
        return true

    # Finds and returns the intersection time if it exists.
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
        return BT2D.Constants.NO_INTERSECTION if @_type != UNBOUNDED and u < -0
        return BT2D.Constants.NO_INTERSECTION if @_type == SEGMENT and u > 1

        # culling based on the input line type.
        ot = ray.getType()

        # There is no intersection if the ray is pointed the wrong direction or doesn't go anywhere.
        return BT2D.Constants.NO_INTERSECTION if ot != UNBOUNDED and v < -0
        return BT2D.Constants.NO_INTERSECTION if ot == SEGMENT and v > 1

        # Return the time of intersection.
        return v

    # Classify the incoming THREE.Vector3 point and return one of the following:
    # Returns BT2D.LEFT on one side of the line.
    # Returns BT2D.ON if the point is on the line.
    # Returns BT2D.RIGHT if the point is on the other side of the line.
    #@ Override BT2D.BinaryPartitioner
    # A line side test for any of the three line like structures.
    side_test: (c) ->
        return ((@_p2.x - @_p1.x)*(c.y - @_p1.y) - (@_p2.y - @_p1.y)*(c.x - @_p1.x))


    # Returns a representative point 'pt' such that @side_test(pt) = BT2D.ON
    #@ Override BT2D.BinaryPartitioner
    representative_point: () ->
        return _p1.clone()

    # populates the intersection between the ray and this Binary partitioner.
    # if the binary partitioner was made from a line segment, then it will return the intersection on the line containing the segment,
    # even if the intersection is not inside of the segment.
    # If the binary partitioner is of non-trivial width, it should return the intersection on the halfplane not containing the origin of the incoming ray.
    # returns a positive time if a valid intersection exists, otherwise returns BT2D.Constants.NO_INTERSECTION_TIME, which is guranteed to be negative.
    #@ Override BT2D.BinaryPartitioner
    ray_partition_intersection_time: (ray) ->
        saveType = @_type
        @makeUnbounded()
        time = @_intersectRayTime()
        @_type = saveType
        return time

    getPosition: (time) ->
        offset = @dir.clone()
        offset.multiplyScalar(time)
        location = getP1()
        location.add(offset)
        return location