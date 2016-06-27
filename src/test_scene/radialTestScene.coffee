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
    
        inc = Math.PI*2/n
        for i in [0...Math.PI*2] by inc
            # Create the inner flood lights.
            @createPolarSurface(@emmissiveSourceMaterial, 5, i + inc/10, i + inc + inc/10)
            # Create the outer fully absorbtive walls.
            @createPolarSurface(@absorptiveSourceMaterial, 50, i + inc*3/2, i + inc/2)

        # Finally trace the frustrums.
        @traceFrustrums()
    

    # Here are two helper functions for our test scene.
    createPolarSurface: (material, radius, angle1, angle2) ->
        p1 = new THREE.Vector3( radius*Math.cos(angle1), radius*Math.sin(angle1), 0 );
        p2 = new THREE.Vector3( radius*Math.cos(angle2), radius*Math.sin(angle2), 0 );

        geometry = new BT2D.Line(p1, p2)
                       
        surface = new BT2D.Surface(geometry, material)
        @addSurface(surface)