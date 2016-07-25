###
    ArraySurfaceSet

    Written by Bryce Summers on 7/2/2016
    
    Purpose:
     - This class represents a set of surfaces using an array.
     - This class is meant to be used as leaf nodes in a BSP.
     - BSP trees will likely use these with non-intersecting surfaces.
###

class BT2D.LeafSurfaceSet # implements BT2D.Geometry, BT2D.Set

    # INPUTS: BT2D.Surface[]
    constructor: (surface_set) ->
   
        # A set of Surfaces
        @_set = []

        # Add all of the input surfaces to this set.
        for surface in surface_set
            @addSurface(surface)
    
    # TODO: Change this to 'add'
    addSurface: (surface) ->
        
        @_set.push(surface)
    
    # TODO: Change this to 'clear'
    clearSurfaces: ->
        @_set = []

    # @Override BT2D.Geometry.
    intersectRay: (ray, intersection, min_time) ->

        # Note: For leaf surface, sets, we assume that they don't contain any occluding geometry,
        # such that any object intersected with a frustrum is within the cast front.

        for surface in @_set
            if surface.intersectRay(ray, intersection, min_time)
                return true           
        return false


    # @Override BT2D.Geometry.
    # Note: For leaf surface, sets, we assume that they don't contain any occluding geometry,
    # such that any object intersected with a frustrum is within the cast front.
    intersectFrustrum: (frustrum, min_time1, min_time2) ->
        
        for surface in @_set
            [found, left, right, surface] = surface.intersectFrustrum(frustrum, min_time1, min_time2)

            if found
                return [true, left, right, surface]

        return [false, null, null, null]