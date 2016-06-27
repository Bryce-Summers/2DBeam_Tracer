###
    Surface

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
        This class describes a physical surface that associates a geoemtry with a material.
         - The geometry describes an embedding in space.
         - The material describes the light tranport properties of this surface.
###

class BT2D.Surface
    constructor: (@geometry, @material) ->
    
    isEmissiveSource: ->
        return @material.isEmissiveSource()
        
        
    # FIXME: I need to think about how to properly encode a circular emmitted frustrum.
    # Returns a BT2D.LightFrustrum Object.
    emitSourceFrustrums: () ->
        
        if @geometry instanceof BT2D.Line
            line = @geometry
            p1  = line.getP1()
            p2  = line.getP2()
            dir = line.getNormal().multiplyScalar(-1)
            frustrum         = new BT2D.Frustrum(p1, p2, dir, dir)
            initial_spectrum = @material.getEmmissiveSourceSpectrum()
            lightFrustrum    = new BT2D.LightFrustrum(frustrum, initial_spectrum, initial_spectrum)
            return [lightFrustrum]

        console.log("ERROR: NON-line emmissive surfaces are not supported yet.")

    # Returns radiant frustrums cooresponding to the irradiant frustrums coming in.
    # The intersection event gives us geometry details about what happened.
    # REQUIRES: the incoming frustrum should be composed of two rays that both intersect this surface.
    #           In other words, frustrums should already be split in parts cooresponding to each surface they hit.
    emitScatteringFrustrums: (incomingLightFrustrum, intersection) ->
        input_frustrum = incomingLightFrustrum.frustrum

        # For now, compute perfect specular reflection.
        if @geometry instanceof BT2D.Line
            

            # Since we are prefectly reflecting, the orientation has changed and we therefore reverse the 1 and 2 rays
            # when reading from the inputs.
            spectrum_1 = incomingLightFrustrum.getEndSpectrum2()
            spectrum_2 = incomingLightFrustrum.getEndSpectrum1()

            # Dont't emit any scattering frustrums that don't have enough energy left.
            if spectrum_1.imperceptible() && spectrum_2.imperceptible()
                return []

            incoming_dir1 = input_frustrum.dir2
            incoming_dir2 = input_frustrum.dir1

            end1 = input_frustrum.getEnd2()
            end2 = input_frustrum.getEnd1()

            line = @geometry
            outgoing_dir1 = line.getPerfectSpecularReflectionDirection(incoming_dir1)
            outgoing_dir2 = line.getPerfectSpecularReflectionDirection(incoming_dir2)

            scattered_frustrum = new BT2D.Frustrum(end1, end2, outgoing_dir1, outgoing_dir2)

            lightFrustrum    = new BT2D.LightFrustrum(scattered_frustrum, spectrum_1, spectrum_2)
            return [lightFrustrum]

        console.log("ERROR: Non-line surfaces are currently not supported for light scattering.")
   

    # Intersect min fills out the intersection information iff there is an intersection in the forward ray direction that is less than any intersection thus far.
    # returns iff there was an intersection found for this call (regardless of whether an intersection has been found previously.)
    intersectRay: (ray, intersection) ->
        if @geometry.intersectRay(ray, intersection)
            intersection.surface = @
            return true
        else
            return false