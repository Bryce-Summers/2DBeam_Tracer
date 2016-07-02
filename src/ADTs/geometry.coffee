###
    Geometry interface.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This is the super class that defines all geometry objects.
###

# This is an interface for objects that allow intersection queries.

class BT2D.Geometry

    constructor: ->


    # populates the intersection object if a closer intersection is found in the forward ray direction.
    # returns true if an intersection exists.
    # this should be overriden for every subclass.
    # Implementations should make no assumptions about the given intersection object being empty.
    intersectRay: (ray, intersection, min_time) ->
        console.log("ERROR: BT2D: intersectRay. This method should be overriden.")
        return false

    #(BT2D Frustrum, BT2D.Intersection[])
    # Returns the sub frustrum that lies to the left of the intersection,
    # a list of the two intersection points,
    # and the sub frustrum that lies to the right of the intersection,
    # Returns (left_Frustrum, Intersection[], right_frustrum)
    # Returns [null, null, null] if no intersection was found.
    intersectFrustrum: (frustrum, min_time1, min_time2) ->
        console.log("ERROR: BT2D: intersectFrustrum. This method should be overriden.")
        return false