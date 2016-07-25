###
    FrustrumTracer class

    Written by Bryce Summers on 6/18/2016.

    Purpose:
     - This class traces frustrums, given a surface model of the scene.

     - This is very similar to a traditional ray tracer, just more exciting.

###

class BT2D.FrustrumTracer
    constructor: () ->

    
    # surfaceSet: INPUT LinearSurfaceSet, lightFrustrumSet: OUTPUT
    traceFrustrums: (surfaceSet, lightFrustrumSet) ->
    
        # FIXME: Eventually only trace those frustrums that need updating, instead of clearing and retracing all of the frustrums.
        lightFrustrumSet.clearAll()
        
        # Get a set of frustrums populated with start and directional information.
        incomplete_frustrum_set = surfaceSet.emitSourceFrustrums()

        # FIXME: I am going to emit a point light source.
        incomplete_frustrum_set = @addPointLight()

        # We Complete all of the frustrums through ray tracing and also derive the associated lightFrustrums.
        # NOTE: the 'initial_frustrums' will now contain completed data.
        i = 0
        while i < incomplete_frustrum_set.length

            lightFrustrum = incomplete_frustrum_set[i]
            i++

            # We derive a set of completed frustrums from the given incomplete light frustrum and any resulting radiated light scattering frustrums.
            scattered_frustrum_set = @_traceFrustrum(lightFrustrum, surfaceSet)

            if scattered_frustrum_set == null
                continue;

            # Add the completed frustum to the output set.
            lightFrustrumSet.addLightFrustrum(lightFrustrum)

            # Then enqueue all of the scattered frustums into the incomplete_frustrums set.
            for scattered_frustrum in scattered_frustrum_set
                incomplete_frustrum_set.push(scattered_frustrum)

    # FIXME: This is just for testing purposes.
    addPointLight: () ->

        center = new THREE.Vector3( BT2D.mouse_x, BT2D.mouse_y, 0)
        #center = BT2D.center

        left   = new THREE.Vector3(-1,  0, 0)
        right  = new THREE.Vector3( 1,  0, 0)
        up     = new THREE.Vector3( 0,  1, 0)
        down   = new THREE.Vector3( 0, -1, 0)

        NW = new THREE.Vector3(-1, 2, 0)
        NE = new THREE.Vector3( 1, 2, 0)

        fullIntensitySpectrum = new BT2D.Spectrum(1.0, 1.0, 1.0)
        noIntensitySpectrum   = new BT2D.Spectrum(0.0, 0.0, 0.0)
        full = fullIntensitySpectrum

        emmissiveSourceMaterial  = new BT2D.Material(fullIntensitySpectrum)
        absorptiveSourceMaterial = new BT2D.Material(noIntensitySpectrum)

        #f0 = new BT2D.Frustrum(center, center, NW, NE)
        f0 = new BT2D.Frustrum(center, center, left, right)
        lightf0 = new BT2D.LightFrustrum(f0, full, full, null)# NULL --> it doesn't start anywhere.

        
        f1 = new BT2D.Frustrum(center, center, right, left)
        lightf1 = new BT2D.LightFrustrum(f1, full, full, null)# NULL --> it doesn't start anywhere.
        

        return [lightf0]


    # BT2D.LightFrustrum (incomplete), BT2D.LinearSurfaceSet
    # Completes the lightFrustrum, by finding its ending points within the surfaceSet.
    # We are currently keeping this function encapsulated, so that we can reorganize the data dance once we work on frustrum splitting, and light scattering.
    # ENSURES: completes the input light Frustrum.
    # RETURNS: a set of incomplete light frustrums that will need to be traced.
    _traceFrustrum: (lightFrustrum, surfaceSet) ->


        [found, left, right, surface] = surfaceSet.intersectFrustrum(lightFrustrum, -BT2D.Constants.EPSILON, -BT2D.Constants.EPSILON)

        if !found
            console.log("ERROR: Frustrum was not properly completed.");
            debugger;
            return null;

        # We now populate the set of all split and scattered frustrums that will need to be traced.
        output = []
        # We push the split frustrums first, because that will lead to better cache coherence,
        # but also it will ensure that if we implement a maximum time limit later the frustrums will have been traced in more of a breadth first, 
        #rather than depth first order.
        # If we really care about that then we can change this to explicitly return the bounced and split frustrums separatly.
        # We will need to do that anyways if we want to get cache locality boosts.
        # FIXME (See above)
        output.push(left) if left != null
        output.push(right) if right != null
        
        #zzzsurface.emitScatteringFrustrums(lightFrustrum, output)

        return output


    # BT2D.LightFrustrum (incomplete), BT2D.LinearSurfaceSet
    # Completes the lightFrustrum, by finding its ending points within the surfaceSet.
    # We are currently keeping this function encapsulated, so that we can reorganize the data dance once we work on frustrum splitting, and light scattering.
    # ENSURES: completes the input light Frustrum.
    # RETURNS: a set of incomplete light frustrums scattered due to the collision event.
    _traceFrustrumNaive:(lightFrustrum, surfaceSet) ->

        # FIXME: For now we are going to super naively trace rays to wherever they go in the scene and will ignore degenerate cases.

        intersection = new BT2D.Intersection()
        
        frustrum = lightFrustrum.frustrum
        
        ray1 = new BT2D.Ray(frustrum.getStart1(), frustrum.getDir1())
        ray2 = new BT2D.Ray(frustrum.getStart2(), frustrum.getDir2())
        
        end1  = null
        end2  = null
        dist1 = null
        dist2 = null
        
        # Check for an intersection2 and if so complete the frustrum.
        if surfaceSet.intersectRay(ray1, intersection, BT2D.Constants.EPSILON)
            end1  = intersection.computePosition(ray1)
            dist1 = intersection.time
        else
            debugger
            console.log("ERROR: We are not able to properly handle view bounded frustrums yet.")
            return []
        
        intersection.clear()

        if surfaceSet.intersectRay(ray2, intersection, BT2D.Constants.EPSILON)
            end2  = intersection.computePosition(ray2)
            dist2 = intersection.time
        else
            debugger
            console.log("ERROR: We are not able to properly handle view bounded frustrums yet.")
            return []

        # TODO: Put logic for constructing appropiate ending point, when no intersection exists.
        if end1 != null && end2 != null
            lightFrustrum.complete(end1, end2, dist1, dist2)

        # FIXME: I need to properly split the frustrums by the surfaces they are intersecting.

        # Compute the set of incomplete radiated light scattering effect frustrums.
        surface = intersection.surface

        output = []
        surface.emitScatteringFrustrums(lightFrustrum, output)
        return output;