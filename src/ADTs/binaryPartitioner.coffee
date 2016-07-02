###
    Binary Partitioner Interface.

    Written by Bryce Summers on 6/26/2016.
    
    Purpose:
     - Binary Partitioners are able to partition incoming points into the spaces defined by the parttioner.
     - i.e. for a line, the spaces would be the two half planes on either side of the line and the set of all points on the line.
###



class BT2D.BinaryPartitioner
    constructor: ->

    # Use an analogue to a line side test to 
    # Classify the incoming THREE.Vector3 point and return one of the following:
    # BT2D.LEFT, BT2D.ON, BT2D.RIGHT
    side_test: (pt) ->
        console.log("Interface only.")
        debugger;

    # Returns a representative point 'pt' such that @side_test(pt) = BT2D.ON
    representative_point: () ->
        console.log("Interface only.")
        debugger;


    # populates the intersection between the ray and this Binary partitioner.
    # if the binary partitioner was made from a line segment, then it will return the intersection on the line containing the segment,
    # even if the intersection is not inside of the segment.
    # If the binary partitioner is of non-trivial width, it should return the intersection on the halfplane not containing the origin of the incoming ray.
    # returns a positive time if a valid intersection exists, otherwise returns BT2D.Constants.NO_INTERSECTION_TIME, which is guranteed to be negative.
    ray_partition_intersection_time: (ray) ->
        console.log("Interface only.")
        debugger;        