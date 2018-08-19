// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

/*
 * Extra information about a piece of vocabulary for human help in the console.
 */
@:expose
class VocabMeta {
    public var description: String;
    public var example: String;

    public function new(description: String, example: String) {
        this.description = description;
        this.example = example;
    }
}
