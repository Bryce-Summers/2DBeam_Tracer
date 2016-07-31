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
        blueSpectrum = new BT2D.Spectrum(0.0, 0.0, 1.0)
        redSpectrum = new BT2D.Spectrum(1.0, 0.0, 0.0)


        @emmissiveSourceMaterial  = new BT2D.Material()
        @emmissiveSourceMaterial.setEmissive(fullIntensitySpectrum)

        # DEFAULT material...
        @absorptiveSourceMaterial = new BT2D.Material()

        # Converts all red energy into blue energy...
        @specularSourceMaterial = new BT2D.Material()
        @specularSourceMaterial.setSpecularBlue(redSpectrum)


        @createScene(n)

    createScene: (n) ->
    
        @clearSurfaces()

        
        # generate the scene.
        #@createPolarTestScene(n)
        @createBasicTestScene(n)
        
        #@createRandomScene(n)

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
            @createPolarSurface(@specularSourceMaterial, 50, i + inc*3/2 , i + inc/2)

    createRandomScene: (n) ->
        for i in [0 ... n]
            v1 = @randomVector(50)

            length = 5

            angle = Math.random()*Math.PI*2
            offset = new THREE.Vector3(5*Math.cos(angle), 5*Math.sin(angle), 0)

            v2 = v1.clone().add(offset)
            @createSurface(
                    @specularSourceMaterial,
                    #@absorptiveSourceMaterial
                v1,
                v2)

    randomVector: (max) ->
        x = Math.random()*max*2 - max
        y = Math.random()*max*2 - max
        z = 0#Math.random()*max*2 - max
        return new THREE.Vector3(x, y, z)


    createBasicTestScene: (n) ->
        ###
        @createSurface(@emmissiveSourceMaterial,
            new THREE.Vector3( -5, -35 + 1.01*n, 0),
            new THREE.Vector3( 5 - n*1.07, -30, 0)
            )
        ###

        ###
        # A wall in the middle of the screen.
        @createSurface(@specularSourceMaterial,
            new THREE.Vector3( -10, -1, 0)
            new THREE.Vector3(  10, 3, 0))

        # A wall in the middle of the screen.
        @createSurface(@absorptiveSourceMaterial,
            new THREE.Vector3(  -10, -1, 0)
            new THREE.Vector3(   -5, 5, 0))

        ###

        @createSurface(@specularSourceMaterial,
            new THREE.Vector3(  -10, 20, 0)
            new THREE.Vector3(   20, -10, 0))

        @createSurface(@specularSourceMaterial,
            new THREE.Vector3(  -20, 10, 0)
            new THREE.Vector3(  1, 5, 0))


    # Here are two helper functions for our test scene.
    createPolarSurface: (material, radius, angle1, angle2) ->
        p1 = new THREE.Vector3( radius*Math.cos(angle1), radius*Math.sin(angle1), 0 );
        p2 = new THREE.Vector3( radius*Math.cos(angle2), radius*Math.sin(angle2), 0 );

        geometry = new BT2D.Line(p2, p1)
                       
        surface = new BT2D.Surface(geometry, material)
        @addSurface(surface)

    # this function creates walls on the edges of the scene.
    createViewBoundaryWalls: () ->

        x0 = -50.01
        x1 =  50.01
        y0 = -50.01
        y1 =  50.01

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
