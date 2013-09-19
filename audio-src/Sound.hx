// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Sound {
    public var txt : StringBuf;

    private function show(x: Int, n: Int) {
        for (i in 0...n) {
            var v : Int = x % 256;
            txt.addChar(v);
            x >>= 8;
        }
    }

    private function show_header(sample_len: Int) {
        txt.addSub("RIFF",0);
        show(36+sample_len,4);
        txt.addSub("WAVE",0);
        txt.addSub("fmt ",0);
        show(16,4);
        show(1,2);
        show(1,2);
        show(16000,4);
        show(16000,4);
        show(1,2);
        show(8,2);
        txt.addSub("data",0);
        show(sample_len,4);
    }

    private function render(text : String) {
        var unit_len : Int = 4000;
        var char_len : Int = text.length;
        var sample_len : Int = unit_len*char_len;
        var variation : Float = 0.5;
        var qraise : Float = Math.sqrt(Math.sqrt(2));
        var qminor : Float = 2;
        var base : Float = 2;
        show_header(sample_len);

        var v : Float = 0;
        var n_prev : Float = 0;
        var n2_prev : Float = -1;
        var k_prev : Int = 4;
        for (i in 0...char_len) {
            var k : Int = text.charCodeAt(i) - '0'.code;
            var n : Float = k;
            var n2 : Float = -1;
            var chord : Int = 0;
            if (k==2) { base = base*qraise;  n = base; chord = 1; }
            if (k==3) { base = base/qraise;  n = base; chord = 1; }
            if (k==0) { n2 = base/qminor;  n = base; }
            if (k==1) { n2 = base*qminor;  n = base; }
            for (j in 0...unit_len) {
                var q : Float = 0;
                var factor : Float = j/80.0;
                var tweak : Float = 1-Math.abs(j-unit_len/2)/(unit_len/2);
                // omitted integer division here
                if (factor>1) { factor = 1; }
                if (k!=4 && k!=5) {
                    q += factor*100*Math.sin((n)*v);
                    if (n2>=0) {
                        q += factor*20*Math.sin((n2)*v);
                    }
                    if (chord!=0) {
                        //q += tweak*factor*12*sin((n*qminor)*v);
                        //q += tweak*factor*12*sin((n/qminor)*v);
                    } else {
                    }
                }
                if (k_prev!=4 && k_prev!=5) {
                    if (i!=0) {
                        q += (1-factor)*100*Math.sin((n_prev)*v);
                    }
                }
                if (n2_prev>=0) {
                    q += (1-factor)*20*Math.sin((n2_prev)*v);
                }
                if (k==4 || k==5) {
                    if (k==4) {
                        q += tweak*factor*50*Math.sin(base*v);
                        q += tweak*factor*25*Math.sin(2*base*v);
                    } else {
                        q += tweak*factor*50*Math.sin(base*v);
                        q += tweak*factor*25*Math.sin(2*base*v);
                        q += tweak*factor*12*Math.sin(4*base*v);
                        q += tweak*factor*12*Math.sin(8*base*v);
                    }
                }
                show(128+Std.int(q),1);
                v += 0.1;
            }
            n_prev = n;
            k_prev = k;
            n2_prev = n2;
        }
    }



    public static function main() : Void {
        var content_mode : Bool = true;
        var default_text : String = "01234543210";
        var text : String = default_text;
        for (arg in Sys.args()) {
            text = arg;
            if (text.charAt(0)=="-") {
                switch (text.charAt(1)) {
                case 'w':
                    content_mode = false;
                    break;
                }
            }
        }
        var self : Sound = new Sound();
        if (content_mode) {
            /*
            text = default_text;
            char *data;
            data = getenv("QUERY_STRING");
            if(data != NULL) {
                if (data[0]=='s') {
                    if (data[1]=='=') {
                        text = data+2;
                    }
                }
            }
            */

            self.txt.addSub("Content-Type: audio/x-wav",0);
            self.txt.addChar(10);
            self.txt.addChar(10);
            //printf("%c%c",10,10);
        }
        self.render(text);
        Sys.stdout().writeString(self.txt.toString());
    }

    public function new() {
        txt = new StringBuf();
    }
}