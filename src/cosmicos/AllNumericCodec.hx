// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
public ParseCodec implements Codec {
    private var vocab : Vocab;

    public function new(vocab: Vocab) {
        this.vocab = vocab;
    }

    public function encode(src: Statement) : Bool {
        var txt : String = cast src.content[0];
        src.content = Parse.stringToList(txt);
        return true;
    }

    public function decode(src: Statement) : Bool {
        return true;
    }
}
