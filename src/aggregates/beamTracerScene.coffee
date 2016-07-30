###
    Beam Tracer Scene object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents and entire 2D Beam Tracer mathematical scene model.
    
    Components:
     - A linearSurfaceSet, which represents the set of surfaces that make up the geometry of the scene.
       This set also keeps a record of emmissive sources of light.
     - A camera that specifies the current view of the scene.
     - A set of Frustrums
###

class BT2D.BeamTracerScene
    constructor: ->
    
        @_surfaceSet       = new BT2D.SurfaceSet()
        @_lightFrustrumSet = new BT2D.LightFrustrumSet()
        
        # This flag is let external renderers know if the frustrums have changed.
        @frustrumsNeedUpdate = false

        @_initCamera()
        
        @_frustrumTracer = new BT2D.FrustrumTracer()
        
        
    _initCamera: ->
        # Setup the current cameraView of the Scene.
        # FIXME: We need to properly determine how to handle view dimensions.
        width  = 100
        height = 100
        @_camera = new THREE.OrthographicCamera( width / -2, width / 2, height / 2, height / -2, 1, 1000 )
        @_camera.position.z = 2

    #surface BT2D.Surface
    addSurface: (surface) ->
            
        @_surfaceSet.add(surface)
        @surfacesChanged = true

    createSurface: (material, p1, p2) ->
        geometry = new BT2D.Line(p1, p2, )
        surface = new BT2D.Surface(geometry, material)
        @addSurface(surface)
        
    clearSurfaces: () ->
        @_surfaceSet.clear()
        @surfacesChanged = true

    generateBSP: () ->
        @_surfaceSet.generateBSP()

    # This needs to be called externally to indicate that the user is ready to trace the frustrums.
    traceFrustrums: ->
    
        # There is no need to trace the frustrums if the surfaces have not changed and any user input light sources have not changed.
        return if !@surfacesChanged and not BT2D.mouse_changed
        
        # Converts the surface set into a set of LightFrustrums.
        @_frustrumTracer.traceFrustrums(@_surfaceSet, @_lightFrustrumSet)
        @surfacesChanged = false
        @frustrumsNeedUpdate = true
        
    # Takes in a frustrum drawer and updates its triangle set based on this scene's model.
    frustrumsToTriangles:(frustrumDrawer) ->
    
        # FIXME: Replace this naive implementation with one that only modifies those frustrums that have been elliminated or changed.
        frustrumDrawer.clearTriangles()
        @_lightFrustrumSet.convertToTriangles(frustrumDrawer)
        @frustrumsNeedUpdate = false

    # Provides the current view of the scene.
    getCamera: ->
        return @_camera