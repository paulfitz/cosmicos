import {Rename} from '../cosmicos/Rename';

const cosmicos = require('lib/cosmicos').cosmicos;

export type PrintCallback = (x: string) => void;

export default class Eval {
  private cc: any;
  private cache: string = '';
  private rename: Rename = new Rename();

  public constructor() {
    this.cc = new cosmicos.Evaluate(null,true);
    
    this.cc.applyOldOrder();
    this.cc.addStd();
  }

  public clean(input: string): string {
    input = this.rename.renameWithinString(input);
    input = "" + input;  // make sure this really is a string :-/
    let len = input.length;
    if (len>=3) {
      if (input[0]=='(' && input[len-1]==')' && input[len-2]=='\n') {
        // old-style node repl - strip extra parens
        input = input.substr(1,len-2);
      }
    }
    len = input.length;
    if (len>0) {
      if (input[len-1]=='\n') {
        // strip newline
        input = input.substr(0,len-1);
      }
    }
    len = input.length;
    if (len>=2) {
      if (input[0]=='(' && input[len-1]==')') {
        // we don't wrap top level statements any more
        input = input.substr(1,len-2);
      }
    }
    return input;
  }
  
  public apply(input: string, print: PrintCallback): string|number|boolean|undefined {
    input = this.clean(input);
    var input0 = input;
    if (this.cache!="") {
      input = this.cache + input;
    }
    let out: any = "";
    try {
      if (input==="help") {
        out+= "Syntax:\n";
        out+= "  Space-separated lists of names and numbers with nesting e.g.: * 3 (+ 1 (+ 2 3))\n";
        out+= "  Shorthand: \"|\" nests to end of expression: (+ 1 | + 2 3) is equiv. to (+ 1 (+ 2 3))\n";
        out+= "             \"$x\" is equivalent to \"(x)\"\n";
        out+= "  Lists are evaluated by calling the first element with each of the others in turn.\n";
        out+= "  If the first element of the list is a name or number, it is treated as a lookup.\n";
        out+= "  Exception: \"? x body\" makes a function\n";
        out+= "             \"if cond A B\" evaluates to A if cond is true, otherwise B\n";
        out+= "             \"define x v\" means that looking up $x will return v\n\n";
        out+= "      Symbol  Meaning when called               Example\n";
        var vocab = this.cc.getVocab();
        var names = vocab.getNames();
        for (var i=0; i<names.length; i++) {
          var lout = "";
          var name = names[i];
	  var origName = this.rename.unget(name);
	  var idx = "";
	  for (let j=idx.length; j<5; j++) {
	    lout += " ";
	  }
	  lout += idx;
	  lout += " ";
	  lout += origName;
	  for (let j=origName.length; j<7; j++) {
	    lout += " ";
	  }
          var meta = vocab.getMeta(name);
          var e = meta ? meta.description : null;
	  if (e) {
	    lout += " " + e;
	    for (let j=e.length; j<33; j++) {
	      lout += " ";
	    }
	    var ex = meta ? meta.example : null;
	    if (ex) {
	      lout += " " + ex;
	    }
	  }
	  lout += "\n";
          if (e) {
            out += lout;
          }
        }
        print(out);
        out = null;
      } else if (input==="examples") {
        print(this.cc.examples().join("\n") + "\n");
        out = null;
      } else {
        out = this.cc.evaluateLine(input);
        if (out==null) {
	  this.cache += input0 + "\n";
        } else {
	  var v = parseInt(out);
	  if (""+v === out) { out = v; }
	  this.cache = "";
        }
      }
    } catch (e) {
      this.cache = "";
      out = "" + e;
    }
    if (this.cache=="") {
      return out;
    }
    return undefined;
  }
}
