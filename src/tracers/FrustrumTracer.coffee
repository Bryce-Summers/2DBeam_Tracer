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

        # We Complete all of the frustrums through ray tracing and also derive the associated lightFrustrums.
        # NOTE: the 'initial_frustrums' will now contain completed data.
        i = 0
        while i < incomplete_frustrum_set.length

            lightFrustrum = incomplete_frustrum_set[i]
            i++

            # We derive a set of completed frustrums from the given incomplete light frustrum and any resulting radiated light scattering frustrums.
            scattered_frustrum_set = @_traceFrustrum(lightFrustrum, surfaceSet)

            # Add the completed frustum to the output set.
            lightFrustrumSet.addLightFrustrum(lightFrustrum)

            # Then enqueue all of the scattered frustums into the incomplete_frustrums set.
            for scattered_frustrum in scattered_frustrum_set
                incomplete_frustrum_set.push(scattered_frustrum)

    # BT2D.LightFrustrum (incomplete), BT2D.LinearSurfaceSet
    # Completes the lightFrustrum, by finding its ending points within the surfaceSet.
    # We are currently keeping this function encapsulated, so that we can reorganize the data dance once we work on frustrum splitting, and light scattering.
    # ENSURES: completes the input light Frustrum.
    # RETURNS: a set of incomplete light frustrums scattered due to the collision event.
    _traceFrustrum: (lightFrustrum, surfaceSet) ->
        # FIXME: For now we are going to super naively trace rays to wherever they go in the scene and will ignore degenerate cases.
        
        intersection = new BT2D.Intersection()
        
        frustrum = lightFrustrum.frustrum
        
        ray1 = new BT2D.Ray(frustrum.getStart1(), frustrum.dir1)
        ray2 = new BT2D.Ray(frustrum.getStart2(), frustrum.dir2)
        
        end1  = null
        end2  = null
        dist1 = null
        dist2 = null
        
        # Check for an intersection2 and if so complete the frustrum.
        if surfaceSet.intersectRay(ray1, intersection, BT2D.Constants.EPSILON)
            end1 = intersection.computePosition(ray1)
            dist1 = intersection.time
        else
            console.log("ERROR: We are not able to properly handle view bounded frustrums yet.")
            return []
            
        if surfaceSet.intersectRay(ray2, intersection, BT2D.Constants.EPSILON)
            end2 = intersection.computePosition(ray2)
            dist2 = intersection.time
        else
            console.log("ERROR: We are not able to properly handle view bounded frustrums yet.")
            return []

        # TODO: Put logic for constructing appropiate ending point, when no intersection exists.
        if end1 != null && end2 != null
            lightFrustrum.complete(end1, end2, dist1, dist2)

        # FIXME: I need to properly split the frustrums by the surfaces they are intersecting.

        # Compute the set of incomplete radiated light scattering effect frustrums.
        surface = intersection.surface
        return surface.emitScatteringFrustrums(lightFrustrum, intersection)