###
    Material

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class specifies the Bdrf and other light transport properties of a surface.
     - In otherwords, this class specifies how to an input frustrum with an associated spectrum
       gets transformed into outgoing spectrums.
       
     - Every piece of geometry needs to be associated with a material in order to interact with spectrum frustrums.
     
     # NOTE: Materials should for the most part be read only.
###

class BT2D.Material
 
    # This needs a lot of work.
    constructor: (@emissive) ->
        # FIXME.
        #@emmisive = new BT2D.spectrum()
        
    isEmissiveSource: ->
        return !@emissive.imperceptible()
        
    
    getEmmissiveSourceSpectrum: ->
        return @emissive.clone()