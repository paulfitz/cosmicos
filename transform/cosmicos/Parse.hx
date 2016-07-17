// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Parse {

    public static function removePipes(x: String, bracketlevel: Int) : String {
    //trace(x);

      var res : String = "";

      // first get rid of ; at the end

      var ch = x.charAt(x.length-1);
      if (ch == ';') {
        x = x.substr(0,x.length-1);
      }
      // borrow code from stringToList and stringToListCore

      var level = 0;
      var slashes = 0;
      var appendstr = "";
      var substring = "";
      var oldch = ''; // for saving the old character in string

      for (i in 0...x.length) {
        var ch = x.charAt(i);

        var delta_level = 0;
        appendstr = "";

        if (ch == "(") {
          level++;
          delta_level = 1;
        }
        if (ch == ")") {
          level--;
          delta_level = -1;
        }

        if (level == 0)
        // only perform tests at highest level and
        // solve rest via recursion
        {
          if (ch == "|" || ch == "/") {
            // remove | at highest level
            slashes++;
            appendstr = '(';
          }
          else
          {
            appendstr = ch;
            if ((oldch == '/' || oldch == '|') && appendstr == " ") // removing spaces after |
              appendstr = "";
          }
          if (delta_level == -1) // substring analysis finished
          {
            appendstr = "(" + removePipes(substring.substr(1,substring.length), bracketlevel+1) + ")"; // first char is "("
            // will not be performed on initial step
            substring = "";
          }


        }
        else
        // all strings below level = 0 should go into some substring
        // and are interpreted afterwards
        {
          substring += ch;
        }

        res += appendstr;

        /*trace("ch: " + ch +
        " oldch: " + oldch +
        " lev: " + level +
        " delta " + delta_level +
        " sub " + substring +
        " bracketlevel: " + bracketlevel +
        " append \'" + appendstr + "\'");*/

        oldch = ch; // for removing spaces directly after | or /
      }

      for (i in 0...slashes) {
        res += ')';
      }


      return res;
    }

    public static function removeDollars(x: String) {
      var terminalsymbols = " ();";
      var founddollar = false;
      var res = "";
      var dollarstring = "";

      // after these symbols the substring search for $ symbols should terminate

      for (i in 0...x.length) {
        var ch = x.charAt(i);
        if (ch == "$") {
          founddollar = true;
        }
        if (founddollar) {
        // if dollar string is found add chars up to substring
        // and write back substring after terminal symbol is found
          if (terminalsymbols.indexOf(ch) != -1) {
            res += "(" + dollarstring + ")"; // reconstruct () from $
            res += ch;
            dollarstring = ""; // reset substring
            founddollar = false; // reset dollar flag
          }
          else {
            if (ch != '$')
              dollarstring += ch; // ch belongs to $ string
          }

        }
        else
          res += ch; // if non dollar string is found just copy old string
      }


      return res;

    }


    public static function preprocessString(x: String) : String {
      var res = removePipes(x, 0); // start at level zero and remove | elements
      res = removeDollars(res); // transform $x into (x)
      return res;
    }


    public static function stringToList(x: String,
                                        vocab: Vocab) : Array<Dynamic> {
	//trace(x);
        var ch = x.charAt(x.length-1);
        if (ch == ';') {
            x = x.substr(0,x.length-1);
        }
        var level = 0;
        for (i in 0...x.length) {
            var ch = x.charAt(i);
            if (ch=='('||ch=='{') level++;
            if (ch==')'||ch=='}') level--;
        }
        if (level!=0) return null;
        var result = stringToListCore(x,vocab);
        //trace(""+result);
        return result;
    }

    public static function stringToListCore(x: String,
                                            vocab: Vocab) : Array<Dynamic> {
        var result : Array<Dynamic> = [];
        var prefix : Array<Dynamic> = [];
        x = " " + x + " )";
        var cache = "";
        var level = 0;
        var slashed = false;
        for (i in 0...x.length) {
            var ch = x.charAt(i);
            if (ch=='\n'||ch=='\r'||(ch==';'&&level<0)) ch = ' ';
            if (ch=='('||ch=='{') {
                level++;
                if (level==1) continue;
            }
            // add this in when getting strict about '|' instead of '/'
            //if (ch=='/' && level==0) {
            //  throw("'/' should be '|' now in " + x);
            //}
            if ((ch=='/'||ch=='|') && level==0) {
                level = 1;
                slashed = true;
                continue;
            }
            if (ch==')'||ch=='}') {
                level--;
                if (level==0) {
                    var r = stringToListCore(cache,vocab);
                    result.push(r);
                    if (slashed) {
                        result[result.length-1].unshift(-1);
                        slashed = false;
                    }
                    cache = "";
                    continue;
                }
            }
            if (ch==';') {
                if (level>(slashed?1:0)) cache += ch;
            } else {
                if (ch!=' '||level>0) cache += ch;
            }
            if (level==0&&(ch==' '||ch==';')&&cache.length>0) {
                if (cache.charAt(0)=='$') {
                    cache = cache.substr(1,cache.length-1);
                    result.push([-2, cache]);
                } else {
                    result.push(cache);
                }
                cache = "";
            }
            if (ch==';'&&level==1&&slashed) {
                var r = stringToListCore(cache,vocab);
                result.push(r);
                if (slashed) {
                    result[result.length-1].unshift(-1);
                    slashed = false;
                }
                prefix.push(result);
                result = new Array<Dynamic>();
                cache = "";
                level = 0;
                continue;
            }
            if (ch==';'&&level==0) {
                prefix.push(result);
                result = new Array<Dynamic>();
                cache = "";
                continue;
            }
        }
        if (prefix.length>0) {
            if (result.length==0) {
                result = prefix;
            } else {
                result = prefix.concat(result);
            }
        }
        return result;
    }

    public static function encodeSymbols(e: Array<Dynamic>,
                                         vocab: Vocab) {
        for (i in 0...e.length) {
            var v : Dynamic = e[i];
            if (Std.is(v,Array)) {
                var ei : Array<Dynamic> = cast v;
                encodeSymbols(ei,vocab);
            } else if (v==-1 || v==-2) {
                continue; // marks source of nesting (/|$)
            } else {
                var str : String = cast v;
                var ch0 = str.charAt(0);
                if (ch0<'0'||ch0>'9') {
                    if (ch0 == ":" || ch0 == ".") {
                        v = new BitString(str);
                    } else if (ch0 == "U" && ~/^U1*U$/.match(str)) {
                        // unary number e.g. U111U represent as string
                        v = str.substr(1,str.length-2);
                    } else if (ch0 == "\"" || ch0 == "\'") {
                        // will need to tweak this for utf8, for
                        // now ASCII ok
                        var len : Int = str.length;
                        var u : BigInteger = BigInteger.ofInt(0);
                        var times : BigInteger = BigInteger.ofInt(256);
                        for (j in 1...(len-1)) {
                            u = u.mul(times);
                            u = u.add(BigInteger.ofInt(str.charCodeAt(j)));
                        }
                        v = u;
                        /*
                    } else if (~/^.*-in-unary$/.match(str) && vocab!=null) {
                        var v0 : Int = vocab.get(str.substr(0,str.length-9));
                        var u : String = "";
                        for (j in 0...v0) u += '1';
                        v = u;
                        */
                    } else if (vocab!=null) {
			trace("found string \"" + str + "\"; looking up vocab");
                        v = vocab.getBase(str); // TODO: should be getBase?
			trace("found code \"" + v + "\"");
                    }
                } else {
		    trace("converting number " + str);
                    v = Std.parseInt(str); // convert numbers to bitcodes
		    trace("to " + v);
                }
                e[i] = v;
            }
        }
    }

    public static function removeSlashMarker(e: Array<Dynamic>) {
        for (i in 0...e.length) {
            var v : Dynamic = e[i];
            if (Std.is(v,Array)) {
                var ei : Array<Dynamic> = cast v;
                removeSlashMarker(ei);
            }
        }
        if (e.length>0) {
            if (e[0] == -1 || e[0] == -2) {
                e.shift();
            }
        }
    }

    public static function cons(x:Dynamic,y:Dynamic) {
        return function(f) { return f(x)(y); };
    }

    public static function car(x:Dynamic) {
        return x(function(a) { return function(b) { return a; }});
    }

    public static function cdr(x:Dynamic) {
        return x(function(a) { return function(b) { return b; }});
    }

    public static function textify(e: Dynamic, vocab: Vocab) : String {
        var txt = "";
        if (Std.is(e,Array)) {
            var lst : Array<Dynamic> = cast e;
            var len : Int = lst.length;
            txt += "(";
            for (i in 0...len) {
                if (i>0) txt += " ";
                txt += textify(lst[i],vocab);
            }
            txt += ")";
            return txt;
        }
        var v = vocab.reverse(e);
        if (v==null) return "" + e;
        return e + "-" + v;
    }

    public static function deconsify(e: Dynamic) : Dynamic {
        if (Std.is(e,Int)) return e;
        if (Std.is(e,BigInteger)) return e;
        if (Std.is(e,String)) return e;
        if (Std.is(e,BitString)) return e;
        var c = new Cursor(e);
        var lst = new Array<Dynamic>();
        var len = c.length();
        for (i in 0...len) {
            var ei = c.next();
            lst.push(deconsify(ei));
        }
        return lst;
    }

    public static function consify(e: Dynamic) : Dynamic {
        if (!Std.is(e,Array)) return e;
        var lst : Array<Dynamic> = cast e;
        var len : Int = lst.length;
        if (len==0) return cons(0,0);
        if (len==1) return cons(1,consify(lst[0]));
        var r = cons(consify(lst[len-2]),consify(lst[len-1]));
        for (i in 0...(len-2)) {
            r = cons(consify(lst[len-3-i]),r);
        }
        return cons(len,r);
    }

    public static function codifyInner(e: Array<Dynamic>, level: Int) : String {
        var txt : String = "";
        var need_paren : Bool = (level>0);
        var first : Int = 0;
        if (e.length>0) {
            if (e[0] == -1) {
                txt += "023";
                need_paren = false;
                first++;
            }
        }
        if (need_paren) txt += "2";
        for (i in first...e.length) {
            var v : Dynamic = e[i];
            if (Std.is(v,Array)) {
                var ei : Array<Dynamic> = cast v;
                txt += codifyInner(ei,level+1);
            } else if (Std.is(v,BitString)) {
                var bs : BitString = cast v;
		trace(bs);
                var str : String = bs.txt;
                var len : Int = str.length;
                if (str.length == 0 || str.charAt(0) == '1') {
                    txt += "0";
                    for (j in 0...len) txt += "1";
                    txt += "0";
                } else {
                    for (j in 0...len) txt += (str.charAt(j)==':')?"1":"0";
                }
            } else {
                var b = "";
                var rem : Int = cast v;
                do {
                    b = ((rem%2!=0)?"1":"0") + b;
                    rem = Std.int(rem/2);
                } while (rem!=0);
                txt += "2" + b + "3";
		trace(b); // debug
            }
        }
        if (need_paren) txt += "3";
        return txt;
    }

    public static function codify(e: Array<Dynamic>) : String {
        var txt : String = codifyInner(e,0);
        txt += "2233";
        return txt;
    }

    public static function integrate(e0: Dynamic) : Dynamic {
        if (Std.is(e0,Int)||Std.is(e0,BigInteger)) {
            return e0;
        }
        if (Std.is(e0,String)) {
            var str : String = cast e0;
            if (str.length==0 || str.charAt(0) == '1') {
                return str.length;
            }
            return e0;
        }
        var lst : Array<Dynamic> = cast e0;
        var len : Int = lst.length;
        for (i in 0...len) {
            lst[i] = integrate(lst[i]);
        }
        return e0;
    }

    public static function recoverList(e: Array<Dynamic>) {
        for (i in 0...e.length) {
            var v : Dynamic = e[i];
            if (Std.is(v,Array)) {
                var ei : Array<Dynamic> = cast v;
                recoverList(ei);
            } else {
                e[i] = recover(v);
            }
        }
    }

    public static function recover(x: Dynamic) : Dynamic {
        if (Std.is(x,Int)) {
            return x;
        }
        if (Std.is(x,BigInteger)) {
            var txt = "";
            var mod = BigInteger.ofInt(256);
            while (x.compare(BigInteger.ZERO)>0) {
                var rem = x.mod(mod);
                txt = String.fromCharCode(rem.toInt()) + txt;
                x = x.div(mod);
            }
            return "\"" + txt + "\"";
        }
        var txt = "";
        if (Std.is(x,Array)) {
            var lst : Array<Dynamic> = cast x;
            var len : Int = lst.length;
            txt += "(vector ";
            for (i in 0...len) {
                if (i>0) txt += " ";
                txt += recover(lst[i]);
            }
            txt += ")";
            return txt;
        }
        if (Std.is(x,String)) {
            return x;
        }
        return "???";
    }
}
