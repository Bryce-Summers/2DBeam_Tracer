###
    Surface

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
        This class describes a physical surface that associates a geoemtry with a material.
         - The geometry describes an embedding in space.
         - The material describes the light tranport properties of this surface.
###

class BT2D.Surface
    constructor: (@_geometry, @_material) ->

    isEmissiveSource: ->
        return @_material.isEmissiveSource()
        
        
    # FIXME: I need to think about how to properly encode a circular emmitted frustrum.
    # Returns a BT2D.LightFrustrum Object.
    emitSourceFrustrums: () ->
        
        if @_geometry instanceof BT2D.Line
            line = @_geometry
            p1  = line.getP1()
            p2  = line.getP2()
            # Note: The orientations need to be consistent such that p1 and p2 are on the
            # left and right sides of the frustrum respectively.
            dir = line.getNormal()
            frustrum         = new BT2D.Frustrum(p1, p2, dir, dir)
            initial_spectrum = @_material.getEmmissiveSourceSpectrum()
            lightFrustrum    = new BT2D.LightFrustrum(frustrum, initial_spectrum, initial_spectrum, @_geometry)
            return [lightFrustrum]

        console.log("ERROR: NON-line emmissive surfaces are not supported yet.")

    # Pushes to the output set radiant frustrums cooresponding to the irradiant frustrums coming in.
    # The intersection event gives us geometry details about what happened.
    # REQUIRES: the incoming frustrum should be composed of two rays that both intersect this surface.
    #           In other words, frustrums should already be split in parts cooresponding to each surface they hit.
    # Pushes to the output array.
    # Returns true iff it pushed at least one frustrum.
    emitScatteringFrustrums: (incomingLightFrustrum, output) ->

        input_frustrum = incomingLightFrustrum.frustrum

        # For now, compute perfect specular reflection.
        if @_geometry instanceof BT2D.Line

            # Since we are prefectly reflecting, the orientation has changed and we therefore reverse the 1 and 2 rays
            # when reading from the inputs.
            spectrum_1 = incomingLightFrustrum.getEndSpectrum2()
            spectrum_2 = incomingLightFrustrum.getEndSpectrum1()

            # Dont't emit any scattering frustrums that don't have enough energy left.
            if spectrum_1.imperceptible() && spectrum_2.imperceptible()
                return false

            # Yet again we swap the order.
            incoming_dir1 = input_frustrum.getDir2()
            incoming_dir2 = input_frustrum.getDir1()

            debugger;
            end1 = input_frustrum.getEnd2().sub(incoming_dir1.clone().multiplyScalar(BT2D.Constants.EPSILON*2))
            end2 = input_frustrum.getEnd1().sub(incoming_dir2.clone().multiplyScalar(BT2D.Constants.EPSILON*2))

            if end1.clone().sub(end2).length() < BT2D.Constants.MINNIMUM_SCATTER_SEPARATION
                console.log("Discarding small frustrum.");
                return

            line = @_geometry

            outgoing_dir1 = line.getPerfectSpecularReflectionDirection(incoming_dir1)
            outgoing_dir2 = line.getPerfectSpecularReflectionDirection(incoming_dir2)

            scattered_frustrum = new BT2D.Frustrum(end1, end2, outgoing_dir1, outgoing_dir2)

            lightFrustrum    = new BT2D.LightFrustrum(scattered_frustrum, spectrum_1, spectrum_2, @_geometry)
            output.push(lightFrustrum)
            return true

        console.log("ERROR: Non-line surfaces are currently not supported for light scattering.")


    # Intersect min fills out the intersection information iff there is an intersection in the forward ray direction that is less than any intersection thus far.
    # returns iff there was an intersection found for this call (regardless of whether an intersection has been found previously.)
    intersectRay: (ray, intersection, min_time) ->
        if @_geometry.intersectRay(ray, intersection, min_time)
            intersection.surface = @
            return true
        else
            return false

    # @Override
    intersectFrustrum: (frustrum, min_time1, min_time2) ->
        [found, left, right, surface] = @_geometry.intersectFrustrum(frustrum, min_time1, min_time2)
        if found
            surface = @
        return [found, left, right, surface]

    # Returns two BT2D.Surface objects that preserve this surface's material properties,
    # but have geometry split along the given binary partitioner.
    # [left, middle, right]
    # Any non-existant surfaces are returned as null.
    split: (bp) ->

        # FIXME: Splitting should just return this surface if no splitting is needed.
        [left, middle, right] = @_geometry.split(bp)

        left_output = null
        middle_output = null
        right_output = null

        if left != null
            left_output  = new BT2D.Surface(left,  @_material)

        if right != null
            right_output = new BT2D.Surface(right, @_material)

        if middle != null
            middle_output = new BT2D.Surface(middle, @_material)

        return [left_output, middle_output, right_output]


    # Returns a binary classifier representing this surface.
    getBP : () ->
        if @_geometry instanceof BT2D.Line
            return @_geometry

        console.log("ERROR: For non lines, e.g. circles and whatnot, we need to support area containing binary classifiers.")