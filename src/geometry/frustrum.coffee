###
    Frustrum object.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This class represents the geometry of individual frustrums,
     - Along with associated starting and ending data and spectrum data.
     
     
    Representation:
     - The Frustrum is represented by 4 2D vector locations, 
       represented by 2 pairs of starting and ending points.
     - the ray start1 -> end1 is represented guranteed to be to the left ( counter-clockwise ) of start2 -> end2
     
     The frustrum is said to be complete then it has all 4 points, but imcomplete it it only has the near points defined.
###
class BT2D.Frustrum

    # The two directions are only used temporarily for use in the casting completion proccess.
    # the direction vectors may be modified externally for making proper directions.
    constructor: (_start1, _start2, @dir1, @dir2) ->
        @validateOrientation()
    
        @_start1 = _start1
        @_start2 = _start2
    
        # At the start, we do not yet have proper ending points,
        # we only have directions.
        @_end1 = null
        @_end2 = null
        
    # Make sure that the orientation of the two rays is correct.
    validateOrientation: () ->
        # TODO.

    # THREE.vector3's
    complete: (end1, end2) ->
        @_end1 = end1.clone()
        @_end2 = end2.clone()
        
    getStart1: () -> @_start1
    getStart2: () -> @_start2
    
    getEnd1: () -> @_end1
    getEnd2: () -> @_end2
        


