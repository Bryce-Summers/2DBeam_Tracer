###
    LightFrustrumSet

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
    
        A set of frustrums illuminated via associated with spectrum attributes.
     
###

class BT2D.LightFrustrumSet
    constructor: ->
       
        @_set = []
    
    addLightFrustrum: (lightFrustrum) ->
    
        @_set.push(lightFrustrum)
        
    convertToTriangles: (frustrumDrawer) ->
    
        frustrum.convertToTriangles(frustrumDrawer) for frustrum in @_set
        
    # Clears all of the light frustrums from this set.
    clearAll: ->
        @_set = []