###
    LightFrustrum

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
    
        This class represents a frustrum illuminated via
        spectrum paths.
        
    Representation the colors coorespond to the vertices in the following order:
            start1(), start2(), getEnd2(), frustrum.getEnd1()

    The LightFrustrum is said to be complete then it has all 4 points, but imcomplete it it only has the near points defined.
###

class BT2D.LightFrustrum
    constructor: (@frustrum, @spectrum1, @spectrum2) ->
        @spectrum3 = null
        @spectrum4 = null
        
    
    # Complete the Light Frustrum with the far side.
    complete: (end1, end2, dist1, dist2) ->
        @frustrum.complete(end1, end2)
        
        # We compute the spectrums of the ending colors merely as a function of the distance that they have travelled.
        
        # End 1.
        @spectrum4 = @spectrum1.decay(dist1)
        
        # End 2.
        @spectrum3 = @spectrum2.decay(dist2)
        
    getEndSpectrum1: () ->
        return @spectrum4

    getEndSpectrum2: () ->
        return @spectrum3

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