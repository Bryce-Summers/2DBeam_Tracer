###
    Material

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class specifies the Bdrf and other light transport properties of a surface.
     - In otherwords, this class specifies how to an input frustrum with an associated spectrum
       gets transformed into outgoing spectrums.
       
     - Every piece of geometry needs to be associated with a material in order to interact with spectrum frustrums.
     
     # NOTE: Materials should for the most part be read only

     Materials will from hereafter be mostly used through the interface of the transformSpectrums function.

     I am opting for a default constructor that supplies the fully absorptive material and users can gradually
     enable all spectrum transformations that they desire.
###

class BT2D.Material
 
    constructor: () ->

        # FIXME: Find out how to factor these out to class scope constants.
        NONE = new BT2D.Spectrum(0.0, 0.0, 0.0)

        @emissive = NONE

        @specular_red   = NONE
        @specular_green = NONE
        @specular_blue  = NONE

    # INPUT: BT2D.Spectrum.
    setEmissive: (s) ->
        @emissive = s

    setSpecularRed: (s) ->
        @specular_red = s

    setSpecularGreen: (s) ->
        @specular_green = s

    setSpecularBlue: (s) ->
        @specular_blue = s
        
    isEmissiveSource: ->
        return !@emissive.imperceptible()
    
    getEmmissiveSourceSpectrum: ->
        return @emissive.clone()


    # The spectrums and incoming directions are assumed to constitute inputs from a light frustrum.
    # It is the responsibility of this material to properly apply its light transport properties to it.
    transformSpectrums: (spectrum_1, spectrum_2, incoming_dir1, incoming_dir2) ->

        # FIXME: As of right now please pardon our dust.
        # we will completely ignore the incoming directions for the time being.

        spectrum_1 = @_transformSpectrum(spectrum_1)
        spectrum_2 = @_transformSpectrum(spectrum_2)

        return [spectrum_1, spectrum_2]

    _transformSpectrum: (s) ->
        red   = s.mult(@specular_red).getTotalEnergy()
        green = s.mult(@specular_green).getTotalEnergy()
        blue  = s.mult(@specular_blue).getTotalEnergy()

        return new BT2D.Spectrum(red, green, blue)

    # FIXME: I belive that there should be a second function here for rays, once we get around to supporting them
    # FIXME: I might want to implement a function that checks for conservation of energy for those folks that care about that sort of thing...