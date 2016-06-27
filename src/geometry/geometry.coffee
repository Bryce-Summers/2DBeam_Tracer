###
    Geometry object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This is the super class that defines all geometry objects.
###

class BT2D.Geometry
    constructor: ->
    
    
    # populates the intersection object if a closer intersection is found in the forward ray direction.
    # returns true if an intersection was found for this particular query.
    # this should be overriden for every subclass.
    intersectRay: (ray, intersection) ->
        console.log("ERROR: BT2D: intersectRay. This method should be overriden.");
        return false