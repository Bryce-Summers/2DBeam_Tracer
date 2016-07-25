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

    # Input: BT2D.Surface[]
    constructor: (surface_set) ->

        if surface_set.length == 0
            console.log("ERROR, surface set should be non trivial.")
            debugger
        
        @_left = null  # Set of all objects strictly left of the BP.

        @_set = null # implements BT2D.Set and BT2D.Geometry (Probably a linear surfaceSet)
              # this specifies all data elements entirely on the Binary partitioner.

        @_right = null # Set of all objects strictly right of the BP.

        @_bp = null

        [@_bp, bp_surface] = @_choosePartitioner(surface_set)

        [left, middle, right] = @_partitionInput(surface_set, @_bp, bp_surface)

        if left.length > 0
            @_left = new BT2D.BSP(left)

        if right.length > 0
            @_right = new BT2D.BSP(right)

        if middle.length > 0
            @_set = new BT2D.LeafSurfaceSet(middle)
        else
            console.log("ERROR: we assume that @_set is always well defined.")

    # REQUIRES: surfaceSet.length > 0
    # returns (bp, surface)
    _choosePartitioner: (surfaceSet) ->

        # FIXME: Use some sort of intelligent heuristic for choosing a valid classifier.
        surface = surfaceSet[0]
        return [surface.getBP(), surface]
        
    #[left, set, right]
    _partitionInput: (surfaceSet, bp, middle_surface) ->
        left   = []
        middle = []
        right  = []

        for surface in surfaceSet

            # FIXME: It would be nice to just remove the middle surface from the 
            # input structure entirely to elliminate this if check.
            if surface == middle_surface
                middle.push(middle_surface)
                continue

            # Splitting should return just one surface if no splitting is needed.
            [left_surface, middle_surface, right_surface] = surface.split(bp)

            left.push(left_surface) if left_surface != null
            middle.push(middle_surface) if middle_surface != null
            right.push(right_surface) if right_surface != null

        return [left, middle, right]



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
        if @_set.intersectRay(ray, intersection, min_time)
            return true

        # No-intersection if there is nothing on the other side.
        if otherSide == null
            return false

        bp_intersection_time = @_bp.ray_partition_intersection_time(ray)
        if bp_intersection_time < min_time #BT2D.Constants.NO_INTERSECTION_TIME
            # Our ray is not tavelling towards the binary partitioner and therefore it cannot intersect any objects inside of it.
            return false

        # We will now check the far halfspace.
        return otherSide.intersectRay(ray, intersection, bp_intersection_time)

    _orientChildSets: (classification) ->
        switch classification

            when BT2D.Constants.LEFT
                return [@_left, @_right]

            when BT2D.Constants.RIGHT
                return [@_right, @_left]

            when BT2D.Constants.ON
                console.log("ERROR: We are assuming starting points that are not on a binary classification boundary.")
                # For now we will just mark these in arbitrary order, because the intersections should be culled anyways.
                return [@_left, @_right]


    #@Override BT2D.Geometry
    intersectFrustrum: (lightFrustrum, min_time1, min_time2) ->

        frustrum = lightFrustrum.frustrum

        # Two rays.
        bp_left  = frustrum.getLeftBP()
        bp_right = frustrum.getRightBP()

        # Two points along the frustrum rays that should be guranteed to be within the space region that is represented by this bsp node.
        pt_left  = bp_left.getPosition(min_time1 + BT2D.Constants.EPSILON*2)
        pt_right = bp_right.getPosition(min_time2 + BT2D.Constants.EPSILON*2)

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

        # -- We must choose the starting classification to determine the order that we will transverse this BSP.

        # Handle case when the two starting points are on the same side of this BSP's partition.
        if classification_left == classification_right
            # This case is easy, since we just use the side that both origin points are on.
            classifier = classification_left
        # Different partitions
        # SLANT LEFT. We should check the right partition first, because it could potentially occlude objects on the left.
        else if time1 == BT2D.Constants.NO_INTERSECTION and time2 != BT2D.Constants.NO_INTERSECTION
            classifier = classification_right
        # SLANT Right. We should check the left partition first, because it could potentially occlude objects on the right.
        else if time1 != BT2D.Constants.NO_INTERSECTION and time2 == BT2D.Constants.NO_INTERSECTION
            classifier = classification_left
        # SLANT OUT (SLANT IN is not handled for frustrum tracing and is assummed to never happen.)
        else
            focus = frustrum.getFocusPoint()
            # If the focus doesn't exist, then the beam is monodirectional and we may make an arbitrary choice.
            # In this case, the frustrum represent a monodiretional beam that runs parrallel to the bsp.
            if focus == null
                classifier = classification_left
            # Given an existant focus, we first search the side containing the focus first.
            else
                classifier = @_bp.side_test(focus)


        # - We now perform the search in the proper order determined as determined by the classifier specified above.

        [frustrum_side, otherSide] = @_orientChildSets(classifier)

        found = false
        left_frustrum = null
        right_frustrum = null
        surface = null

        # Search this side.
        if frustrum_side != null
            [found, left_frustrum, right_frustrum, surface] = frustrum_side.intersectFrustrum(lightFrustrum, min_time1, min_time2)

        if found
            return [true, left_frustrum, right_frustrum, surface]

        # Exit if the frustrum does not go towards the other partition.
        if time1 == BT2D.Constants.NO_INTERSECTION and time2 == BT2D.Constants.NO_INTERSECTION
            return [false, null, null]

        # In these two cases, only one side of the frustrum rays intersects tha partition.
        # SLANT LEFT
        if time1 == BT2D.Constants.NO_INTERSECTION
            #time1 = Number.MAX_VALUE
            ###
            console.log("Does SLANT LEFT really happen?")
            console.log("Yes is does!")
            ###

        # SLANT RIGHT
        if time2 == BT2D.Constants.NO_INTERSECTION
            #time2 = Number.MAX_VALUE
            ###
            console.log("Does this case actually happen?")
            console.log("Yes is does!")
            ###

        
        # Now search partitioning set if no intersection was found on this side of the tracks. ;)
        [found, left_frustrum, right_frustrum, surface] = @_set.intersectFrustrum(lightFrustrum, min_time1, min_time2)

        # Finally search the other side if necessary.
        if (not found) and otherSide != null
            # Note: We subtract out the Epsilons to enable detection of itersections with geoemtry that perfectly end on the binary partition for this node.
            [found, left_frustrum, right_frustrum, surface] = otherSide.intersectFrustrum(lightFrustrum, time1 - BT2D.Constants.EPSILON, time2 - BT2D.Constants.EPSILON)

        return [found, left_frustrum, right_frustrum, surface]