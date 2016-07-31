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
    # BT2D.On will be returned for any point within the area of the binary classifer,
    # so once I implement area classifiers they will have a non-trivial region that returns the on result.
    side_test: (pt) ->
        console.log("Interface only.")
        debugger;

    # Returns a scalar value such that f(pt1) < f(pt2) --> pt1 is left of pt2 in terms
    # of the orientation of this binary classifier.
    side_test_scalar: (pt) ->
        console.log("Interface only.")
        debugger;

    # Efectively sorts the pts via their line side polarity.
    # FIXME: If we wanted to we could add a signed line side test to the spec, but it is not yet needed.
    orientPts: (pt1, pt2) ->
        
        # Reference implementation.
        side1 = @side_test_scalar(pt1)
        side2 = @side_test_scalar(pt2)

        return [pt1, pt2] if side1 < side2
        return [pt2, pt1]

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

    # Returns the percentage of each unit length step of the ray that constitutes movement perpendicular to this binary partitioner.
    getPerpendicularPercentage: (ray) ->
        console.log("Interface only.")
        debugger;

    # returns true iff one of the points in the input pts array is approximatly identical to one of this bp's endpoints,
    # which may have resulted from being cut during the construction of the binary space partition.
    containsEndPoint: (pts) ->
        console.log("Interface only.")
        debugger;
