// Generated by CoffeeScript 1.10.0

/*
    LightFrustrumSet

    Written by Bryce Summers on 6/18/2016.
    
    Purpose:
    
        A set of frustrums illuminated via associated with spectrum attributes.
 */

(function() {
  BT2D.LightFrustrumSet = (function() {
    function LightFrustrumSet() {
      this._set = [];
    }

    LightFrustrumSet.prototype.addLightFrustrum = function(lightFrustrum) {
      return this._set.push(lightFrustrum);
    };

    LightFrustrumSet.prototype.convertToTriangles = function(frustrumDrawer) {
      var frustrum, i, len, ref, results;
      ref = this._set;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        frustrum = ref[i];
        results.push(frustrum.convertToTriangles(frustrumDrawer));
      }
      return results;
    };

    LightFrustrumSet.prototype.clearAll = function() {
      return this._set = [];
    };

    return LightFrustrumSet;

  })();

}).call(this);
