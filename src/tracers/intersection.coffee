###
    Intersection object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents an intersection event.
###

class BT2D.Intersection
    constructor: ->
        @clear()
        
    clear: ->
        # float, relevant for ray intersections.
        @time = null
        # the location in space that the intersection occurs at.
        @location = null
        
        # This stores the surface object containing both the geometry and material properties of the stored intersection point.
        @surface = null

    notFound: () ->
        return @time == null and @location == null

    # For efficiency, we only store the minnimum computed data when performing intersections.
    # this function may be used to fill in some of the gaps.
    # FIXME: I will need to think more about this if I decided to implement more than just lines.
    computePosition: (ray) ->
    
        if(@time == null or @time == BT2D.Constants.NO_INTERSECTION)
            console.log("Error in Intersection, time was null.")
            debugger
            throw new Error("Error in Intersection, time was null")
        
        @location = ray.getPosition(@time)
        return @location
        