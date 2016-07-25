###
    The Frustrum drawer class.

    Written by Bryce Summers on 6/18/2016.
    Purpose:
     - This class speaks to Three.js
     - Renders all of the light frustrums to the screen as attribute interpolated triangles.
       where the attributes are the light intensities, represented by THREE.js Colors.
       
    Implementation Details:
     - We draw all of the attribute interpolated triangles with additive blending to sum up the total light contributions at any given point.
       since additive blending is commutative, we don't need to worry about z-fighting,
       even though all of the triangle will be drawn at the same depth.
     - We draw both front and back faces so that we don't need to waste time properly orienting the triangles.
###

class BT2D.FrustrumDrawer
    constructor: ->

        # We will use a ThreeJS geometry for specifying the set of attribute
        # Interpolated Triangles that we will use for drawing the frustrums.
        @_geometry = new THREE.Geometry();
        
        @_scene = new THREE.Scene();

        @_material = new THREE.MeshBasicMaterial({
            vertexColors: THREE.VertexColors
            # We use both sides,
            # so that we don't have to waste time reorienting the triangles to face the camera.
            side: THREE.DoubleSide
            transparent: true
            blending: THREE.AdditiveBlending # Additive blending sums up the contributions for intersecting light frustrums.
            depthTest: false # We negate the depth test to hopefully avoid the need for the non-communitive workarounds.
            
        })

        @_mesh = new THREE.Mesh( @_geometry, @_material );
        @_scene.add( @_mesh );


    # Takes in 3 THREE.vector3 variables and appends a face to this geometry.
    # Also takes in 3 THREE.Color's that specify the vertex color attributes.
    addTriangle: (v1, v2, v3, c1, c2, c3) ->
        
        i0 = @_geometry.vertices.length
        i1 = i0 + 1
        i2 = i0 + 2
            
        @_geometry.vertices.push(v1, v2, v3)

        face = new THREE.Face3(i0, i1, i2)
        # Define Light Intensities at the three points.

        face.vertexColors = [c1, c2, c3]

        @_geometry.faces.push(face)
        @_geometry.elementsNeedUpdate = true

    
    clearTriangles: ->

        # FIXME: It would be much more efficient to maintain a large enough array and then dynamically update the contents and how much of it is used.
        # https://github.com/mrdoob/three.js/issues/342
        @resetGeometryBuffer()
    
        @_geometry.faces = [];
        @_geometry.vertices = [];
        
        # renderer : THREE.js renderer, scene : beamTracerScene

    # THREE.JS supports updating the individual contents of the geometry buffer,
    #    but we can't dynamically resize the arrays after they have been drawn to the screen one.
    # THREE.JS does not support having us resize the geometry buffer.
    # We therefore need to create a new one when we wish to add an alternative set of triangles.
    resetGeometryBuffer: ->
        @_geometry.dispose()
        @_geometry = new THREE.Geometry();
        @_mesh.geometry = @_geometry
        
    render: (renderer, tracerScene) ->

        # If the scene has a modified set of frustrums,
        # we allow if to inform us of how our set of triangles should be updated.
        if tracerScene.frustrumsNeedUpdate
        
            tracerScene.frustrumsToTriangles(@)

            #FIXME: We should render the scene iff the view has changed or the scene has changed.
            console.log(@_scene)
        
            # We then render our set of attribute interpolated triangles.
            renderer.render( @_scene, tracerScene.getCamera())