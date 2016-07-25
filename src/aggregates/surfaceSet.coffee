###
    SurfaceSet

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents a comprehensive set of Surfaces embedded in a plane and specifies a 2D scene graph.
     - This class maintains the set through a spatial partitioning of the plane that allows for:
        - efficient ray - linearSurfaceSet intersections and
        - efficient frustrum - linearSurfaceSet intersections through binary spatial partitioning.
###

class BT2D.SurfaceSet # implements BT2D.Geometry, BT2D.Set
    constructor: ->

        # A set of Surfaces
        @_set = []
        @_emissive_set = []

        # We defer the creation of the Binary Space Partition tree until the scene is fully formed.
        @_bsp = null
    
    #Override BT2D.Set
    add: (surface) ->
        
        # Maintain a set of all surfaces.
        @_set.push(surface)

        # Keep track of those surfaces that are emissive sources.
        @_emissive_set.push(surface) if surface.isEmissiveSource()
    
    #Override BT2D.Set
    clear: ->
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

    # From scratch generates a BSP from the set of surfaces.
    generateBSP: () ->
        @_bsp = new BT2D.BSP(@_set)

    # Returns truee iff a forward intersection was found.
    intersectRay: (ray, intersection, min_time) ->

        if @_bsp == null
            console.log("Error: BSP has not yet been formed.")
            debugger

        return @_bsp.intersectRay(ray, intersection, min_time)

    # @Override BT2D.Geometry
    intersectFrustrum: (frustrum, min_time1, min_time2) ->

        return @_bsp.intersectFrustrum(frustrum, min_time1, min_time2)