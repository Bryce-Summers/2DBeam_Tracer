###
    Spectrum object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents an Electromagnetic radiation spectrum.
     
    What does that mean?

###

# red, green, and blue are stored as floats between 0.0 and 1.0

class BT2D.Spectrum

# FIXME: Put some contant spectrums here, such as 0, 1, etc.

    constructor: (@red, @green, @blue) ->
    
        throw new Error("bad red value") if @red < 0 or @red > 1
        throw new Error("bad green value") if @green < 0 or @green > 1
        throw new Error("bad blue value") if @blue < 0 or @blue > 1

    
    # Returns iff this spectrum is of such a small intensity that
    # it no longer makes a perceivable contribution.
    imperceptible: ->
        return @red + @green + @blue < .01 # FIXME: Think about the cutoff.
        
    toColor: ->
        return new THREE.Color(@red, @green, @blue)

    # Algebraic operations are non-destructive.
    mult: (other) ->
        return new BT2D.Spectrum(@red*other.red, @green*other.green, @blue*other.blue);
        
    multScalar: (s) ->
        return new BT2D.Spectrum(@red*s, @green*s, @blue*s);
        
    add: (other) ->
        return new BT2D.Spectrum(@red + other.red, @green + other.green, @blue + other.blue);
        
    clone: ->
        return new BT2D.Spectrum(@red, @green, @blue)
        
    decay: (dist1) ->
        # FIXME: I need to extract his value to some global property configuration.
        max_length = BT2D.Constants.LIGHT_LENGTH
        return @multScalar(Math.max(0, Math.min(1.0, 1.0 - dist1/max_length)))
        
    