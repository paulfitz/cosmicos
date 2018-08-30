// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
interface Codec {
    function encode(src: Statement) : Bool;

    function decode(src: Statement) : Bool;
}
