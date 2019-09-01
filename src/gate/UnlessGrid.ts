export class UnlessGate {
  public state: boolean = true;
  public nextState: boolean = true;
  public forced: boolean = false;
  public hidden: boolean = false;
  public src: UnlessGate|null = null;
  public dest: UnlessGate|null = null;
  public key: number = 0;

  public block() {
    this.nextState = false;
  }

  public prepareForUpdate() {
    if (!this.forced) {
      this.nextState = true;
      if (this.src!=null) {
	this.nextState = this.src.state;
      }
    }
  }

  public update() {
    if (!this.forced) {
      if (this.state) {
	if (this.dest!=null && !this.hidden) {
	  this.dest.block();
	}
      }
    }
  }

  public finalizeUpdate() {
    if (!this.forced) {
      this.state = this.nextState;
    }
  }

  public set(state: boolean) {
    this.state = state;
    this.forced = true;
  }

  public getSource() {
    return this.src;
  }

  public getDestination() {
    return this.dest;
  }
}


////////////////////////////////////////////////////////////////////////
// UnlessNet

export class UnlessNet {
  public net: UnlessGate[] = [];
  public nodes: {[key: string]: UnlessGate} = {};
  public names: {[key: string]: string} = {};
  public key: number = 1;

  public add(name: string) {
    if (!this.nodes[name]) {
      const node = new UnlessGate();
      node.key = this.key;
      this.key = this.key+1;
      this.nodes[name] = node;
      this.names[node.key] = name;
      this.net.push(node);
    }
  }

  public get(name: string) {
    return this.nodes[name];
  }

  public setSource(name: string, srcName: string) {
    const ref = this.nodes[name];
    if (ref) {
      ref.src = this.nodes[srcName];
    }
  }

  public setDestination(name: string, destName: string) {
    const ref = this.nodes[name];
    if (ref) {
      ref.dest = this.nodes[destName];
    }
  }

  public update() {
    for (let i=0; i<this.net.length; i++) {
      this.net[i].prepareForUpdate();
    }
    for (let i=0; i<this.net.length; i++) {
      this.net[i].update();
    }
    for (let i=0; i<this.net.length; i++) {
      this.net[i].finalizeUpdate();
    }
  }

  public toString() {
    const lines = [];
    for (let i=0; i<this.net.length; i++) {
      const u = this.net[i];
      if (!u.hidden) {
	const name = this.names[u.key];
	const src = u.getSource();
	const dest = u.getDestination();
	let srcName: string = "[1]";
	let destName: string = "[0]";
	if (src) { srcName = this.names[src.key]; }
	if (dest) { destName = this.names[dest.key]; }
        lines.push(`node ${name} (${srcName}:${destName}) = ${u.state}\n`);
      }
    }
    return lines.join('');
  }

  public disconnect() {
    for (let i=0; i<this.net.length; i++) {
      const u = this.net[i];
      u.src = null;
      u.dest = null;
    }
  }
}

////////////////////////////////////////////////////////////////////////
// Pair

export class Pair {
  constructor(public x: number, public y: number) {
  }

  public equals(p: Pair): boolean {
    return p.x===this.x && p.y===this.y;
  }

  public get key(): string {
    return String(257 * this.x + this.y);
  }
}


interface UnlessLine {
  x: number;
  y: number;
  dx: number;
  dy: number;
  name: string
}

////////////////////////////////////////////////////////////////////////
// UnlessGrid

export class UnlessGrid {
  public points: {[key: string]: Pair} = {};
  public pointsList: Pair[] = [];
  public names: {[key: string]: Pair} = {};
  public externalize: {[key: string]: string} = {};
  public ct: number = 0;
  public xbase: number = -1;
  public ybase: number = -1;
  public net: UnlessNet;

  public static parse(str: string): UnlessGrid {
    const grid = new UnlessGrid();
    grid.parse(str);
    return grid;
  }

  public constructor(str?: string) {
    if (str) { this.parse(str); }
  }

  public getBounds() {
    let lx: number = 10000;
    let ly: number = 10000;
    let hx: number = 0;
    let hy: number = 0;
    function check(x: number, y: number) {
      if (x < lx) { lx = x; }
      if (y < ly) { ly = y; }
      if (x > hx) { hx = x; }
      if (y > hy) { hy = y; }
    }
    for (const p of this.pointsList) {
      const dp = this.points[p.key];
      check(p.x, p.y);
      check(p.x + dp.x, p.y + dp.y);
    }
    return [lx, ly, hx, hy];
  }

  public parse(str: string) {
    str = str + "\n";
    let parts: string[] = [];
    let part = "";
    for (let i=0; i<str.length; i++) {
      const ch = str.charAt(i);
      if (ch===' '||ch==='\n'||ch==='\r'||ch==='.') {
        if (part!=="") {
	  parts.push(part);
        }
        part = "";
      }
      if (ch==='\n'||ch==='\r'||ch==='.') {
        if (parts.length>=4) {
	  const x = parseInt(parts[0], 10);
	  const y = parseInt(parts[1], 10);
          // note the inverted order here for ancient, ancient reasons
	  const dx = parseInt(parts[3], 10);
	  const dy = parseInt(parts[2], 10);
	  const name = parts[4];
	  this.add(x,y,dx,dy,name);
        }
        parts = [];
      }
      if ((ch>='0'&&ch<='9')||(ch>='A'&&ch<='Z')||(ch>='a'&&ch<='z')||
	  ch=='_'||ch=='-') {
        part = part + ch;
      }
    }
    this.compile();
  }

  public update() {
    this.net.update();
  }

  public add(x: number, y: number, dx: number, dy: number, label?: string) {
    this.points[(new Pair(x,y)).key] = new Pair(dx,dy);
    this.pointsList.push(new Pair(x,y));
    if (label) {
      this.names[label] = new Pair(x,y);
      this.externalize[this.getName(x,y)] = label;
    }
    if (this.xbase<0) {
      this.xbase = x;
      this.ybase = y;
      if (dy!=0) {
	this.xbase++;
	this.ybase++;
      }
    }
    this.ct++;
  }

  public nearby(x: number, y: number) {
    for (let i=0; i<this.pointsList.length; i++) {
      const pt = this.get(i);
      let nx = (pt.x-x)*(pt.x-x);
      let ny = (pt.y-y)*(pt.y-y);
      if (pt.dx!=0) {
	ny *= 5;
      } else {
	nx *= 5;
      }
      const diff = nx+ny;
      if (diff<1) {
	return i;
      }
    }
    return -1;
  }

  public force(name: string, on: boolean) {
    const pt = this.names[name];
    if (!pt) { throw new Error(`unknown name: ${name}`); }
    const uname = this.getName(pt.x, pt.y);
    const unit = this.net.get(uname);
    if (!unit) { throw new Error(`cannot find: ${name} ${uname}`); }
    unit.forced = true;
    unit.state = on;
  }
  
  public wobble(x0: number, y0: number) {
    const idx = this.nearby(x0,y0);
    let flipped: boolean = false;
    if (idx>=0) {
      const near = this.get(idx);
      const dx = x0-near.x;
      const dy = y0-near.y;
      const p = this.pointsList[idx];
      const dp = this.points[p.key];
      if (Math.abs(dx)>Math.abs(dy)) {
	if (dx*dp.x<0) {
	  dp.x = -dp.x;
	  flipped = true;
	}
      } else {
	if (dy*dp.y<0) {
	  dp.y = -dp.y;
	  flipped = true;
	}
      }
    }
    return flipped;
  }

  public getExternalName(x: number, y: number) {
    return this.externalize[this.getName(x,y)];
  }

  public append(x: number, y: number, net: UnlessNet) {
    const x0 = Math.floor(x+0.5);
    const y0 = Math.floor(y+0.5);
    const dx = Math.abs(x0-this.xbase);
    const dy = Math.abs(y0-this.ybase);
    let gx: number = 0;
    let gy: number = 0;
    if (dx%2==0 && dy%2==0) {
      gx = 1;
    } else {
      gy = 1;
    }
    if ((dx+dy)%2==1) {
      return null;
    }
    const name = this.getName(x0,y0);
    this.add(x0,y0,gx,gy);
    net.add(name);
    this.wobble(x,y);
    net.disconnect();
    this.connect(net);
  }

  public getName(x: number, y: number) {
    return `(${x},${y})`;
  }

  public getLabel(label: string) {
    const p = this.names[label];
    return this.getName(p.x,p.y);
  }

  public length() {
    return this.ct;
  }

  public get(i: number): UnlessLine|null {
    if (i < 0) { return null; }
    const p = this.pointsList[i];
    const dp = this.points[p.key];
    return {x: p.x, y: p.y, dx: dp.x, dy: dp.y, name: this.getName(p.x, p.y)};
  }

  public render(net: UnlessNet) {
    const lines: string[] = [];
    for (var i=0; i<this.ct; i++) {
      let str = "";
      const {x, y, dx, dy, name} = this.get(i);
      const unit = net.get(name);
      if (unit.hidden) continue;
      str += x + " " + y + " " + dy + " " + dx;
      const ext = this.externalize[name];
      if (ext) {
	str += " " + ext;
      }
      str += "\n";
      lines.push(str);
    }
    return lines.join("");
  }

  public renderCos(net: UnlessNet) {
    const lines: string[] = ["(vector \n"];
    for (var i=0; i<this.ct; i++) {
      const {x, y, dx, dy, name} = this.get(i);
      const unit = net.get(name);
      const v = unit.state ? 1 : 0;
      if (unit.hidden) continue;
      const ext = this.externalize[name] || '0';
      let line = "  (vector ";
      line += (x-dx) + " " + (y-dy) + " " + (x+dx) + " " + (y+dy);
      line += " " + v;
      line += " " + ext;
      line += ")";
      line += "\n";
      lines.push(line);
    }
    lines.push(")\n");
    return lines.join("");
  }

  public connect(net: UnlessNet) {
    this.net = net;
    for (let i=0; i<this.ct; i++) {
      const {x, y, dx, dy} = this.get(i);
      var p = this.pointsList[i];
      const rec = this.points[p.key];
      const x0 = x+dx*2;
      const y0 = y+dy*2;
      const x90 = x+dx+dy;
      const y90 = y+dy-dx;
      const x270 = x+dx-dy;
      const y270 = y+dy+dx;
      const rec0 = this.points[(new Pair(x0,y0)).key];
      const rec90 = this.points[(new Pair(x90,y90)).key];
      const rec270 = this.points[(new Pair(x270,y270)).key];
      let blocking: boolean = false;
      let lr: boolean = false;
      if (rec90 && rec270) {
	if (rec90.equals(rec270)) {
	  blocking = true;
	  lr = true;
	}
      }
      if (rec0) {
	if (rec0.equals(rec)) {
	  blocking = false;
	}
      }
      if (blocking) {
	// set appropriate destination
	net.setDestination(this.getName(x,y),
			   this.getName(x+dx+rec90.x,y+dy+rec90.y));
      }
      if (!blocking) {
	if (rec0) {
	  if (rec0.equals(rec)) {
	    // good to src
	    net.setSource(this.getName(x0,y0),
			  this.getName(x,y));
	  }
	}
	if (!lr) {
	  if (rec90) {
	    if (x90-rec90.x===x+dx &&
		y90-rec90.y===y+dy) {
	      // good to src
	      net.setSource(this.getName(x90,y90),
			    this.getName(x,y));
	    }
	  }
	  if (rec270) {
	    if (x270-rec270.x===x+dx &&
		y270-rec270.y===y+dy) {
	      // good to src
	      net.setSource(this.getName(x270,y270),
			    this.getName(x,y));
	    }
	  }
	}
      }
    }	
  }

  public compile() {
    const net = new UnlessNet();
    for (let i=0; i<this.ct; i++) {
      const {name} = this.get(i);
      net.add(name);
    }
    this.connect(net);
    return net;
  }
}
