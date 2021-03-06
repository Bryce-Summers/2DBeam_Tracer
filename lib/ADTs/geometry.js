// Generated by CoffeeScript 1.10.0

/*
    Geometry interface.

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
     - This is the super class that defines all geometry objects.
 */

(function() {
  BT2D.Geometry = (function() {
    function Geometry() {}

    Geometry.prototype.intersectRay = function(ray, intersection, min_time) {
      console.log("ERROR: BT2D: intersectRay. This method should be overriden.");
      return false;
    };

    Geometry.prototype.intersectFrustrum = function(lightFrustrum, min_time1, min_time2) {
      console.log("ERROR: BT2D: intersectFrustrum. This method should be overriden.");
      return false;
    };

    Geometry.prototype.split = function(bp) {
      console.log("ERROR: BT2D: split. This method should be overriden.");
      return false;
    };

    return Geometry;

  })();

}).call(this);
