###
    Intersection object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents an intersection event.
###

class BT2D.Intersection
    constructor: ->
        # float, relevant for ray intersections.
        @time = null
        # the location in space that the intersection occurs at.
        @location = null
        
        # This stores the surface object containing both the geometry and material properties of the stored intersection point.
        @surface = null
        
    # For efficiency, we don't compute the actual location during intersection, unless it is convenient.
    # This function allows a caller to compute the actual position of the intersection once they are sure they care about it.
    computePosition: (ray) ->
    
        if(@time == null)
            console.log("Error in Intersection, time was null.")
        
        offset = ray.getDirection().clone()
        offset.multiplyScalar(@time)
        @location = ray.getOrigin().clone()
        @location.add(offset)
        return @location
        