###
    Radial Test Scene Generator object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class generates a new Radia Test Scene to be used as an example scene for testing the frustrum renderer.
###

class BT2D.RadialTestScene extends BT2D.BeamTracerScene
    constructor: (n) ->
        super()

        # First we construct an emmissive surface in the middle of the [-50, -50] x [50, 50] box.
        # centered at the origin.

        fullIntensitySpectrum = new BT2D.Spectrum(1.0, 1.0, 1.0)
        noIntensitySpectrum   = new BT2D.Spectrum(0.0, 0.0, 0.0)

        @emmissiveSourceMaterial  = new BT2D.Material(fullIntensitySpectrum)
        @absorptiveSourceMaterial = new BT2D.Material(noIntensitySpectrum)
        
        @createScene(n)

    createScene: (n) ->
    
        @clearSurfaces()

        
        # generate the scene.
        @createPolarTestScene(n)
        #@createBasicTestScene(n);

        console.log("Creating scene!")


        @createViewBoundaryWalls()

        # Generate the Binary Space Partition structure that will be used to accelerate search queries.
        @generateBSP()

        # Finally trace the frustrums.
        @traceFrustrums()

        
    createPolarTestScene: (n) ->
        inc = Math.PI*2/n
        for i in [0...Math.PI*2] by inc
            # Create the inner flood lights.
            #@createPolarSurface(@emmissiveSourceMaterial, 5, i + inc/10 + .05, i + inc + inc/10 - .05)
            # Create the outer fully absorbtive walls.
            @createPolarSurface(@absorptiveSourceMaterial, 50, i + inc*3/2 , i + inc/2)

    createBasicTestScene: (n) ->
        ###
        @createSurface(@emmissiveSourceMaterial,
            new THREE.Vector3( -5, -35 + 1.01*n, 0),
            new THREE.Vector3( 5 - n*1.07, -30, 0)
            )
        ###

        
        # A wall in the middle of the screen.
        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3( -10, 0, 0)
            new THREE.Vector3(  10, 3, 0))

        # A wall in the middle of the screen.
        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(  -10, 0, 0)
            new THREE.Vector3(   -5, 5, 0))


    # Here are two helper functions for our test scene.
    createPolarSurface: (material, radius, angle1, angle2) ->
        p1 = new THREE.Vector3( radius*Math.cos(angle1), radius*Math.sin(angle1), 0 );
        p2 = new THREE.Vector3( radius*Math.cos(angle2), radius*Math.sin(angle2), 0 );

        geometry = new BT2D.Line(p2, p1)
                       
        surface = new BT2D.Surface(geometry, material)
        @addSurface(surface)

    # this function creates walls on the edges of the scene.
    createViewBoundaryWalls: () ->

        x0 = -50
        x1 =  50
        y0 = -50
        y1 =  50

        offset = 10

        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(x0 - offset, y0, 0)
            new THREE.Vector3(x1 + offset, y0, 0))

        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(x0 - offset, y1, 0)
            new THREE.Vector3(x1 + offset, y1, 0))

        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(x0, y0 - offset, 0)
            new THREE.Vector3(x0, y1 + offset, 0))

        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(x1, y0 - offset, 0)
            new THREE.Vector3(x1, y1 + offset, 0))
