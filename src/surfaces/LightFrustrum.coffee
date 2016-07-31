###
    LightFrustrum

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
    
        This class represents a frustrum illuminated via
        spectrum paths.
        
    Representation the colors coorespond to the vertices in the following order:
            start1(), start2(), getEnd2(), frustrum.getEnd1()

    The LightFrustrum is said to be complete then it has all 4 points, but imcomplete it it only has the near points defined.

    The source geometry is the geometry that radiated this light frustrum.
    It will be required to ensure that we do not allow a light frustrum to intersect its source, while also allowing light frustrums to intersect geometries
    that intersect the source at the starting points.

    FIXME: I might want to go an make all of these variables private when I get a chance.

    My idea for maintaining this as it gets more complex is to make clones of light frustrums, then only mutate those values as necessary.
###

class BT2D.LightFrustrum
    constructor: (@frustrum, @spectrum1, @spectrum2) ->
        @spectrum3 = null
        @spectrum4 = null
        @_bounces = 0
        @_source_geometry = null
    
    # Complete the Light Frustrum with the far side.
    complete: (end1, end2, dist1, dist2) ->

        if end1.clone().sub(end2).length() < .001
            console.log("ERROR: Bad completion. 2D Beam tracer frustrums are guranteed to never intersect the same end points.");

        @frustrum.complete(end1, end2)
        
        # We compute the spectrums of the ending colors merely as a function of the distance that they have travelled.
        
        # End 1.
        @spectrum4 = @spectrum1.decay(dist1)
        
        # End 2.
        @spectrum3 = @spectrum2.decay(dist2)

    clone: () ->
        output = new BT2D.LightFrustrum(@frustrum, @spectrum1, @spectrum2, @source_geometry)
        output._bounces = @_bounces
        return output

        
    getEndSpectrum1: () ->
        return @spectrum4.clone()

    getEndSpectrum2: () ->
        return @spectrum3.clone()


    # This method is called to provide the light frustrum with information about its light path if it needs it eventually.
    # This information is also use to compute an accurate number of bounces.
    scatteredFrom: (parentLightFrustrum, surface) ->
        @_bounces = parentLightFrustrum.getNumBounces() + 1
        @_souce_geometry = surface

    _copyStatisticsFrom: (other) ->
        @_bounces = other._bounces
        @_source_geometry = other._source_geometry

    getNumBounces: () ->
        return @_bounces

    # BT2D.FrustrumDrawer
    convertToTriangles: (frustrumDrawer) ->

        if @spectrum3 == null or @spectrum4 == null
            console.log("Incomplete Frustrum, likely no intersection was found during tracing.")
            return

        v1 = @frustrum.getStart1()
        v2 = @frustrum.getStart2()
        v3 = @frustrum.getEnd2()
        v4 = @frustrum.getEnd1()
        
        c1 = @spectrum1.toColor()
        c2 = @spectrum2.toColor()
        c3 = @spectrum3.toColor()
        c4 = @spectrum4.toColor()
        
        # Populate the two triangles that will be used to draw the frustrum to the screen.
        #FIXME: Does the decomposition of the quarilateral into two triangles matter? Could it be done the other way?
        frustrumDrawer.addTriangle(v1, v2, v3, c1, c2, c3)
        frustrumDrawer.addTriangle(v3, v4, v1, c3, c4, c1)


    # Returns the left split light frustrum and mutates this light frustrum to be the right split.
    # Properly interpolates the light spectrum values.
    # The input pt represents the left pt of a piece of geometery that does not occlude the left side of this frustrum.
    # Returns null if the split off frustum had trivial area.
    splitLeft : (pt) ->        

        [split_ray, percentage] = @frustrum.getSplitRay(pt)

        # In this case, this frustum only touches the line, but doesn't contain a non trivial intersection area.

        # FIXME: I get the feeling that percentages are not commensurate with world distances and therefore they don't scale well with epsilon.

        if percentage > 1.0 - BT2D.Constants.EPSILON*10 or percentage < 0.0 + BT2D.Constants.EPSILON*10
            console.log("WARNING: A trivial splitLeft was attempted.")
            return null

        left_frustrum = new BT2D.Frustrum(@frustrum.getStart1(), split_ray.getOrigin(),
                                            @frustrum.getDir1(), split_ray.getDirection())

        split_spectrum = @spectrum1.multScalar(percentage).add(@spectrum2.multScalar(1.0 - percentage))
        output = new BT2D.LightFrustrum(left_frustrum, @spectrum1, split_spectrum)
        output._copyStatisticsFrom(@)

        # Now mutate this light spectrum to be the right of the split.
        @spectrum1 = split_spectrum
        @frustrum.setLeftRay(split_ray)

        return output

    # Returns null if the split off frustum had trivial area.
    splitRight : (pt) ->

        ###
        This is where the problem happens.
        ###

        [split_ray, percentage] = @frustrum.getSplitRay(pt)

        # In this case, this frustum only touches the line, but doesn't contain a non trivial intersection area.
        if percentage > 1.0 - BT2D.Constants.EPSILON*10 or percentage < 0.0 + BT2D.Constants.EPSILON*10
            console.log("WARNING: A trivial splitRight was attempted.")
            # Note: This won't necessarily catch all infractions, but later will to the trick when a trivial frustrum is constructed.
            debugger;
            return null
        
        # Construct a frustrum that is the subset of this light frustrum that contains no rays to the left of the line's left point.
        right_frustrum = new BT2D.Frustrum(split_ray.getOrigin(),    @frustrum.getStart2()
                                           split_ray.getDirection(), @frustrum.getDir2())

        split_spectrum = @spectrum1.multScalar(percentage).add(@spectrum2.multScalar(1.0 - percentage))            

        output = new BT2D.LightFrustrum(right_frustrum, split_spectrum, @spectrum2)
        output._copyStatisticsFrom(@)

        # Now mutate this light spectrum to be the left of the split.
        @spectrum2 = split_spectrum
        @frustrum.setRightRay(split_ray)

        return output

    # This will be used to radially orient points, when we need to get a ray from the frustrum to a given point.
    # This doesn't do any bounds checking.
    getSplitRay: (pt) ->
        [split_ray, percentage] = @frustrum.getSplitRay(pt)
        return split_ray

    getOrientationRay: (pt) ->
        return @frustrum.getOrientationRay(pt)