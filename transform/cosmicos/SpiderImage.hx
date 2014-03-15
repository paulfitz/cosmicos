// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
interface SpiderImage {

    function moveTo( x : Float, y : Float ) : Void;
    function lineTo( x : Float, y : Float ) : Void;
    function beginPath() : Void;
    function stroke() : Void;
}
