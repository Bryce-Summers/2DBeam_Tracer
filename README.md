+---------------------------+
+   2D Beam Tracer Project  +
+---------------------------+

View the current version running online at the following URL: https://bryce-summers.github.io/2DBeam_Tracer/

+ -- History -- +

- 6/18/2016: Initiated by Bryce Summers.

- 6/26/2016: The core and documentation is still in development.


+ -- Dependancies -- +

- 6/18/2016: Three.JS for client side rendering.
- 6/18/2016: Coffeescript, for making Bryce's Object Oriented Life easier.

+ -- Building -- +
1. Open up two terminals.
2. Navigate each of them to the folder containing this README.
   It should also contain the index.html file and the Gruntfile.js
   For easy navigation, try shift+click on this fold in windows then choose open command promt here.
   On Linux it is not too difficult. On a map, try dragging the file into the terminal or something of that nature.

3. Automatically compile the coffeescript code to javascript in one terminal:
 coffee -o lib/ -cw src/
4. In the other you can automatically inject all of the source code links into the html file:
 npm install
 grunt

// FIXME: I need to properly handle ray intersections at points where line geometry intersects. the ray should be allowed to stay at the same point, while intersecting a secondary geometry.
// I believe I have handled this for frustrums... We may also need to eventually handle more than two pieces of geometry intersecting at the same location, but hopefully not... 
 
+ -- Contributions you could make -- +
 - Tell people about this project.
 - Add support for svg reading and writing.
 - Add support for your favorite type of file format.
 - Support importing font based paths.
 - Let us know about an obscure light transport behaviour, and consider implementing the frustrum interaction for it.
 - Implement some parralelism in the Frustrum tracing.
 - Use this software in your game, animation, or teaching!
 
 - Add support for 2D surface normal interpolation to properly simulate light transport on curves.
 - Embed the 2D light drawings in space. (This shouldn't be too hard,
   just change the geometry of the triangles in the renderer and perhaps the camera in the frustrum drawer.
 
 
 - Write a Shader for shading the frustrums with a proper quadratic falloff.
   Also, elliminate the frustrums complete dependance on the ending points,
   because right now we can't have the frustrums die off before they hit an ending wall.
   It would also be helpful to calculate different falloffs for condensed beams and those beams that spread out.
   It would also be helpful to calculate the effect of the enironmental gasses on the beams.
 - Sometime in the future we can start thinking about rendering in the presense of non-homogeneous liquids and gasses.
 
+ -- TODO -- +

 - I am currently working on implementing the basics, such as a Binary Space Partitioning tree and proper frustrum scene intersections.

 - Properly Figure out the view dimensions.
 
 - Design the User interface for spectrums, light positioning, etc.
 
 Notes about Three.js
 
 If some feature is not working, you likely need to enable it or set a flag to let three.js know that you have changed something.
 
 
 I should go through and minnimize the scaling of line side test factors and normalize offsets where appropiate to prevent numeric explosions.
 
 + -- Structural thoughts -- +
 Surface is a line segment with an attached material defined by a bdrf.
 Every light is really nothing more than an emmisive material,
 but a point light or circular light is a special case that has an infinite number of outgoing facets.
 


Style guide.

When implementing an interface such as one specified in the ADT folder, put an #@Override Geometry. comment ontop of the function.
Use _name for private class variables and functions that should not be referenced outside of the class.
