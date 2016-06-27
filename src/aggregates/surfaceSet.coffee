###
    SurfaceSet

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents a set of Surfaces embedded in a plane.
     TODO : Think about whether I need to decompose this into linear vs. non-linear surfaces.
     - This class maintains the set through a spatial partitioning of the plane that allows for:
        - efficient ray - linearSurfaceSet intersections through spatial partitioning.
        - efficient frustrum - linearSurfaceSet intersections.
###

class BT2D.SurfaceSet
    constructor: ->
    
        # A set of Surfaces
        @_set = []
        @_emissive_set = []
    
    addSurface: (surface) ->
        
        @_set.push(surface)

        # Keep track of those surfaces that are emissive sources.
        @_emissive_set.push(surface) if surface.isEmissiveSource()
        
    clearSurfaces: ->
        @_set = []
        @_emissive_set = []
        
    emitSourceFrustrums: () ->
        output = []
        # Return an array of all sources of emmissive Spectrums.
        for surface in @_emissive_set
            emmitted_frustrum_set = surface.emitSourceFrustrums()
            for frustrum in emmitted_frustrum_set
                output.push(frustrum)
        return output

    # Returns truee iff a forward intersection was found.
    intersectRay: (ray, intersection) ->

        out = false;
        for surface in @_set
            out |= surface.intersectRay(ray, intersection)
            
        return out