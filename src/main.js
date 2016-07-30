var renderer;
var scene;
var n = 4;
// Define the global BT2D namespace.

function init() {

    //Create a new scene.
    //FIXME: Import an SVG or some other sort of non hard coded scene.
    scene = new BT2D.RadialTestScene(n);
        
    frustrumDrawer = new BT2D.FrustrumDrawer();
    
        
    container = document.getElementById( 'container' );
    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio( window.devicePixelRatio );
    container.appendChild( renderer.domElement );
 
    onWindowResize();
    window.addEventListener( 'resize', onWindowResize, false);
    //window.addEventListener("keypress", onKeyPress);
    window.addEventListener("keydown", onKeyPress);

    window.addEventListener("mousemove", onMouseMove);
}


// Input Events.
function onWindowResize( event )
{
    renderer.setSize( window.innerWidth, window.innerHeight );
}

function onKeyPress( event )
{
    var LEFT  = 37
    var RIGHT = 39
    
    var old_n = n;
    
    switch(event.which)
    {
        case LEFT: n = Math.max(n - 1, 2)
            console.log("LEFT")
            break;
        case  RIGHT: n = Math.min(n + 1, 20)
            console.log("RIGHT")
            break;
        default:
            break;
    }
    
    
    if(n !== old_n)
    {
        scene.createScene(n);
    }
}

function onMouseMove( event )
{
    console.log(event);

    BT2D.mouse_x = (event.x*1.0/window.innerWidth  - .5) * 100;
    BT2D.mouse_y = (event.y*1.0/window.innerHeight - .5) * -100;
    BT2D.mouse_changed = true;

    // Retrace the frustrums.
    scene.traceFrustrums()
}


function animate() {

    requestAnimationFrame( animate );
    render();

}

function render() {

    // We render the scene using the three.js screen renderer and the Beam Tracer scene model.
    frustrumDrawer.render(renderer, scene);
}

init();
animate();