###
    Line object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents 2D line's in a purely geometric sense.
###

class BT2D.Line extends BT2D.Geometry
    constructor: (_p1, _p2) ->
        super()
    
        @_p1 = _p1.clone()
        @_p2 = _p2.clone()
        @_offset = @_p2.clone().sub(@_p1)
        @_dir = @_offset.clone().normalize()
        
        # Rotate the direction to get the normal direction.
        # Naturally it is still normalized.
        @_normal = @_dir.clone()
        temp = @_normal.x
        @_normal.x = -@_normal.y
        @_normal.y = temp
        
    getNormal: () ->
        return @_normal.clone()

    getP1: () -> return @_p1.clone()
    getP2: () -> return @_p2.clone()

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
    
    #@Override Geometry.
    intersectRay : (ray, intersection) ->
        
    
        # Find the intersection point.
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
        as = @_p1;
        bs = ray.getOrigin();
        ad = @_offset;
        bd = ray.getDirection();
        
        dx = bs.x - as.x;
        dy = bs.y - as.y;
        det = bd.x * ad.y - bd.y * ad.x;
        
        # For our intents and purposes a ray doesn't intersect a collinear line segment.
        return false if Math.abs(det) < .0001
        
        u = (dy * bd.x - dx * bd.y) / det;
        v = (dy * ad.x - dx * ad.y) / det;
        
        #console.log("u = " + u + ", " + "v = " + v)
        
        # The intersection is at time coordinates u and v.
        # Note: Time is relative to the offsets, so p1 = time 0 and p2 is time 1.
        # u is the time coordinate for this line.
        # v is the time coordinate for the ray, it is in the ray's normalized space and
        # therefore give a consistent time for comparing ray intersection distances.

        # There is no intersection if the ray doesn't intersect the segment portion.
        return false if u < -0 or u > 1

        # There is no intersection if the ray is pointed the wrong direction or doesn't go anywhere.
        return false if v <= .000001
        
        # Update the intersection.
        intersection.time = v if v > 0 && (intersection.time == null || intersection.time > v)

        # Inform the caller that there was a valid, although perhaps not minimal and updating, intersection for this call.
        return true