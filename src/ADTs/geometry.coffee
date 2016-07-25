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

    #(BT2D.LightFrustrum, float, float)
    # Returns [result, left_frustrum, right_frustrum, surface] all frustrums are LightFrustrums.
    # where left and right are incomplete frustrums that have been split off from the input frustum.
    # Mutates and completes the input frustrum to be the middle frustrum the intersects this geometry.
    # result is a boolean value that indicates if there was an intersection. nothing happens if result returns false.
    # Note: geoemtries only return 1 frustrum, if an entire set of frustrums if desired,
    # they will need to make further search calls useing the output left and right split off frustrums.
    #
    # The surface is the Surface object that the frustrum has hit, this will be needed for light scattering.
    intersectFrustrum: (lightFrustrum, min_time1, min_time2) ->
        console.log("ERROR: BT2D: intersectFrustrum. This method should be overriden.")
        return false

    # Splits this geometry along the given binary space partitioner.
    # Returns two geometries that are on either side of the input binary partitioner.
    # [left, right]
    # return [null, null] if the partitioner doesn't intersect this surface.
    split: (bp) ->
        console.log("ERROR: BT2D: split. This method should be overriden.")
        return false