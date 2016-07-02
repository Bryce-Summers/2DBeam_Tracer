###
    Ray object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents a Ray starting at an origination point and
       proceding infinitely out into space in a particular direction.
###


# FIXME: I feel like I should probably get rid of this class entirely and roll it into the line class, since that would make things easier.

class BT2D.Ray

    # inputs are THREE.Vector3 instances.
    constructor: (_origin, _direction) ->

        @_origin    = _origin.clone()
        @_direction = _direction.clone()
    
    getOrigin: () -> return @_origin.clone()
    getDirection: ()  -> return @_direction.clone()

    getPosition: (time) ->
        offset = @getDirection()
        offset.multiplyScalar(time)
        location = @getOrigin()
        location.add(offset)
        return location


    getType: () ->
        return BT2D.Line.RAY