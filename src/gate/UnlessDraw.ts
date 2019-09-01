import {Canvas} from 'canvas';
import {UnlessGrid} from './UnlessGrid';

export interface DrawOptions {
  scale: number;
  xOffset?: number;
  yOffset?: number;
  showLabels?: boolean;
}

export function draw(cvs: Canvas, grid: UnlessGrid, options: DrawOptions) {
  const sc = options.scale;
  const ix = options.xOffset || 0;
  const iy = options.yOffset || 0;
  const showLabels = options.showLabels === undefined ? true : options.showLabels;
  const offx = 1;
  const offy = 1;
  const ctx = cvs.getContext("2d");
  ctx.fillStyle = "#fafafa";
  ctx.fillRect(0,0,cvs.width,cvs.height);
  for (let i=0; i<grid.length(); i++) {
    const pt = grid.get(i);
    const node = grid.net.get(pt.name);
    if (node.hidden) continue;
     
    const extName = grid.getExternalName(pt.x,pt.y);
    const x = pt.x+offx;
    const y = pt.y+offy;
    if (extName && showLabels) {
      ctx.font = "12px sans-serif";
      ctx.fillStyle = "#000000";
      ctx.strokeStyle = "#0000ff";
      ctx.textBaseline = 'top';
      ctx.fillText(extName,ix+sc*x,iy+sc*y+5);
    }
     
    ctx.beginPath();
    const st = sc*0.6;
    const sf = sc*0.4;
    const ss = sc*0.2;
    const ox = st*(pt.dx);
    const oy = st*(pt.dy);
    const ox2 = sf*(pt.dx);
    const oy2 = sf*(pt.dy);
    ctx.lineWidth = 2;
    if (node.forced) {
      ctx.lineWidth = 4;
    }
    if (node.state) {
      ctx.fillStyle = ctx.strokeStyle = "#ff0000";
    } else {  
      ctx.fillStyle = ctx.strokeStyle = "#0000ff";
    }

    ctx.moveTo(ix+(x+pt.dx)*sc-ox2,iy+(y+pt.dy)*sc-oy2);
    ctx.lineTo(ix+x*sc-ox,iy+y*sc-oy);
    ctx.stroke();

    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(ix+(x+pt.dx)*sc,iy+(y+pt.dy)*sc);
    ctx.lineTo(ix+x*sc+pt.dx*sf-ss*pt.dy,iy+y*sc+pt.dy*sf+ss*pt.dx);
    ctx.lineTo(ix+x*sc+pt.dx*sf+ss*pt.dy,iy+y*sc+pt.dy*sf-ss*pt.dx);
    //ctx.lineTo(ix+x*sc+pt.dx*sf-ss*pt.dy,iy+y*sc+pt.dy*sf+ss*pt.dx);
    // ctx.lineTo(ix+(x+pt.dx)*sc,iy+(y+pt.dy)*sc);
    ctx.closePath();

    // ctx.lineTo(ix+x*sc+pt.dx*sf+ss*pt.dy,iy+y*sc+pt.dy*sf-ss*pt.dx);

    ctx.fill();


  }
}

