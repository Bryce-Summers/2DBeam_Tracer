###
    binary Space Partitioning Tree.

    Written by Bryce Summers on 6/26/2016.
    
    Purpose:
     - This class enable efficient geometric queries by partitioning planar space using surfaces.
###

class BT2D.BSP # implements BT2D.Geometry

    ###

        Creating the BSP.

    ###

    constructor: (surfaceSet) ->

        console.log("Implement Me!")
        debugger

        # FIXME: We still need to create a procedure for creating a BSP.

        # Here are a list of data elements that BSP's will specify.

        @_bp    # binary partitioner BP
        @_left  # Set of all objects strictly left of the BP.

        @_set # implements BT2D.Set and BT2D.Geometry (Probably a linear surfaceSet)
              # this specifies all data elements entirely on the Binary partitioner.

        @_right # Set of all objects strictly right of the BP.


    _choosePartitioner: (surfaceSet) ->


    #[left, middle, right]
    _partitionInput: (bp) ->


        


    ###

        Search Queries using the BSP.

    ###


   	#@Override Geometry.
    # Helper function used in the computation of ray, BSP intersections.
    # populates the intersection object for output.
    # returns true iff an intersection was found.
    # only updates the intersection event if the intersection event is empty or the intersection 
    # found is of an earlier positive value in time than the intersection's data.
    # The start time specifies the starting time when the ray starts in this BSP subset.
    # Note: There is no need to update the time of computed intersections, because they directly use the input ray.
    # We assume in this case that the min time constitutes a time that used to compute the point on the ray used in this BSP sub space.
    intersectRay : (ray, intersection, min_time) ->
        # Get the location of the earliest point along the ray that is inside of the current subspace.
        pt = ray.getPosition(min_time)

        classification = @_bp.side_test(pt)

        [ptSide, otherSide] = @_orientChildSets(classification)

        # First check for intersections on this side of the BP.
        if ptSide != null and ptSide.intersectRay(ray, intersection, min_time)
            return true

        # Now check for an intersection inside the the BP geometry set.
        if @_set.intersectRay(ray, intersection)
            return true

        # No-intersection if there is nothing on the other side.
        if otherSide == null
            return false

        bp_intersection_time = @_bp.ray_partition_intersection(ray)
        if bp_intersection_time < min_time #BT2D.Constants.NO_INTERSECTION_TIME
            # Our ray is not tavelling towards the binary partitioner and therefore it cannot intersect any objects inside of it.
            return false

        # We will now check the far halfspace.
        return otherSide.intersectRay(ray, intersection, bp_intersection_time)

    _orientChildSets: (classification) ->
        switch classification

            when BT2D.Constants.LEFT
                return [_left, _right]

            when BT2D.Constants.RIGHT
                return [_right, _left]

            when BT2D.Constants.ON
                console.log("ERROR: We are assuming starting points that are not on a binary classification boundary.")
                debugger


    #(BT2D Frustrum, BT2D.Intersection[], float)
    # Returns the sub frustrum that lies to the left of the intersection,
    # a list of the two intersection points,
    # and the sub frustrum that lies to the right of the intersection,
    # Returns (left_Frustrum, Intersection[], right_frustrum)
    # Returns null if no intersection was found.
    # Returns [null, null, null] if no intersection was found.
    intersectFrustrum: (frustrum, min_time1, min_time2) ->

        # Two rays.
        bp_left  = frustrum.getLeftBP()
        bp_right = frustrum.getRightBP()

        pt_left  = bp_left.getPosition(min_time1)
        pt_right = bp_left.getPosition(min_time2)

        # classify the left point based on this BSP node's BP.
        classification_left  = @_bp.side_test(pt_left)
        classification_right = @_bp.side_test(pt_right)

        # We will assume that we don't classify any 'ON' points.
        if classification_left == BT2D.Constants.ON or classification_right == BT2D.Constants.ON
            console.log("ERROR: Assumption invalidated, frustum not offset into cell interior, try using a fudge factor.")

        ray_left  = bp_left
        ray_right = bp_right
        time1 = @_bp.ray_partition_intersection_time(ray_left)
        time2 = @_bp.ray_partition_intersection_time(ray_right)

        # We must choose the starting classification to determine the order that we will transverse this BSP.

        # Handle case when the two starting points are on the same side of this BSP's partition.
        if classification_left == classification_right
            # This case is easy, since we just use the side that both origin points are on.
            classifier = classification_left
        # Different partitions
        # SLANT LEFT.
        else if time1 == BT2D.Constants.NO_INTERSECTION and time2 != BT2D.Constants.NO_INTERSECTION
            classifier = classification_right
        # SLANT Right
        else if time1 != BT2D.Constants.NO_INTERSECTION and time2 == BT2D.Constants.NO_INTERSECTION
            classifier = classification_left
        # SLANT OUT (SLANT IN is not handled for frustrum tracing.)
        else
            focus = frustrum.getFocusPoint()
            # If the focus doesn't exist, then the beam is monodirectional and we may make an arbitrary choice.
            if focus == null
                classifier = classification_left
            # Given an existant focus, we can therefore search the side containing the focus first.
            else
                classifier = @_bp.side_test(focus)

        # We now perform the search in the proper order determined above.

        [frustrum_side, otherSide] = @_orientChildSets(classifier)

        # Search this side.
        [left_frustrum, intersections, right_frustrum] = frustrum_side.intersectFrustrum(frustrum, min_time1, min_time2)

        if intersections != null
            return [left_frustrum, intersections, right_frustrum]

        # Exit if the frustrum does not go towards the other partition.
        if time1 == BT2D.Constants.NO_INTERSECTION and time2 == BT2D.Constants.NO_INTERSECTION
            return [null, null, null]

        if time1 == BT2D.Constants.NO_INTERSECTION
            time1 = Number.MAX_VALUE
            console.log("Does this case actually happen?")

        if time2 == BT2D.Constants.NO_INTERSECTION
            time2 = Number.MAX_VALUE
            console.log("Does this case actually happen?")

        # Now search partitioning set if no intersection was found on this side of the tracks. ;)
        if intersections == null
            [left_frustrum, intersections, right_frustrum] = @_set.intersectFrustrum(frustrum, min_time1, min_time2)

        # Finally search the other side if necessary.
        if intersections == null
            [left_frustrum, intersections, right_frustrum] = otherSide.intersectFrustrum(frustrum, time1, time2)

        return [left_frustrum, intersections, right_frustrum]