###
    Geometry object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This is the super class that defines all geometry objects.
###

# This is an interface for objects that allow intersection queries.

class BT2D.Set
    constructor: ->

    add: (object) ->
        console.log("ERROR: BT2D: intersectRay. This method should be overriden.");
        return false

    clear: () ->

    # Option I suppose for now...
    remove: (object) ->