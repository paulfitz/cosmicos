// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class State {
    private var config : Config;
    private var vocab : Vocab;
    private var mem : Memory;

    public function new(config : Config = null) {
        this.config = config;
        vocab = null;
        mem = null;
    }

    public function setConfig(config : Config) {
        this.config = config;
    }

    public function useIntVocab() {
        vocab = new Vocab(true);
    }

    public function getVocab() : Vocab {
        if (vocab == null) vocab = new Vocab();
        return vocab;
    }

    public function getMemory() : Memory {
        if (mem == null) mem = new Memory(null);
        return mem;
    }

    public function getConfig() : Config {
        if (config == null) config = new Config();
        return config;
    }
}
