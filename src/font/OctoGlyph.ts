import {CanvasRenderingContext2D} from 'canvas';

export interface GlyphTool {
  attach(ctx: CanvasRenderingContext2D, w: number, h: number): void;
  count(): number;
  defaultWidth(): number;
  defaultHeight(): number;
  showChar(hasNumber: boolean, m: number, open: boolean, closed: boolean): void;
}

export class OctoGlyph implements GlyphTool {
  private _ctx: CanvasRenderingContext2D;
  private _w: number;
  private _h: number;

  constructor() {
  }

  public attach(ctx: CanvasRenderingContext2D, w: number, h: number) {
    this._ctx = ctx;
    this._w = w;
    this._h = h;
  }

  public count() {
    return 64;
  }

  public defaultWidth() {
    return 80;
  }

  public defaultHeight() {
    return 128;
  }

  public showChar(hasNumber: boolean, m: number, open: boolean, closed: boolean) {
    const c = this._ctx;
    const w = this._w;
    const h = this._h;
    const w2 = w / 2;
    const h2 = h / 2;
    const w4 = w / 4;
    const h4 = h / 4;
    const hd = h / 4;
    const hb = h / 8;
    const wd = w / 4;
    const wb = w / 8;
    if (!hasNumber && m != 0) {
      if (m == 4) {
        // |
        c.moveTo(w - wb, hb);
        c.bezierCurveTo(w2, hb, w2, hb, w2, h4);
        c.lineTo(w2, h - h4);
        c.bezierCurveTo(w2, h - hb, w2, h - hb, wb, h - hb);
        c.stroke();
      } else if (m == 5) {
        // $
        c.moveTo(w2 - wb, h2 + hb);
        c.bezierCurveTo(w2, h2 - hb, w2, h2 - hb, w2 + wb, h2 + hb);
        c.stroke();
      } else if (m == 6) {
        // space
        c.beginPath();
        c.ellipse(w2, h2, 4, 4, 0, 0, 2 * Math.PI);
        c.stroke();
      } else if (m == 7) {
        // EOL
        c.moveTo(w2 - 2 * wb, h2);
        c.bezierCurveTo(w2 - wb, h2 - hb, w2 - wb, h2 - hb, w2, h2);
        c.bezierCurveTo(w2 + wb, h2 + hb, w2 + wb, h2 + hb, w2 + 2 * wb, h2);
        c.stroke();
      }
      return;
    }
    if (m & 1) {
      // vertical line
      c.moveTo(w2, hb);
      c.lineTo(w2, h - hb);
      c.stroke();
    }
    const nw = Math.round(wb * 0.5);
    if (m & 2) {
      // vertical bulge right
      // c.moveTo(w2, hb);
      //c.bezierCurveTo(w2 + wd, h2, w2 + wd, h2, w2, h - hb);
      c.moveTo(w2 + wd, hb);
      c.bezierCurveTo(w2 - nw, h2, w2 - nw, h2, w2 + wd, h - hb);
      c.stroke();
    }
    if (m & 4) {
      // vertical bulge left
      // c.moveTo(w2, hb);
      // c.bezierCurveTo(w2 - wd, h2, w2 - wd, h2, w2, h - hb);
      c.moveTo(w2 - wd, hb);
      c.bezierCurveTo(w2 + nw, h2, w2 + nw, h2, w2 - wd, h - hb);
      c.stroke();
    }
    if (m & 8) {
      // horizontal line
      c.moveTo(wb, h2);
      c.lineTo(w - wb, h2);
      c.stroke();
    }
    if (m & 16) {
      // horizontal bulge down
      c.moveTo(wb, h2);
      c.bezierCurveTo(w2, h2 + hd, w2, h2 + hd, w - wb, h2);
      c.stroke();
    }
    if (m & 32) {
      // horizontal bulge up
      c.moveTo(wb, h2);
      c.bezierCurveTo(w2, h2 - hd, w2, h2 - hd, w - wb, h2);
      c.stroke();
    }
    if (m == 0 && hasNumber) {
      c.moveTo(w2, h4);
      c.lineTo(w - w4, h2);
      c.lineTo(w2, h - h4);
      c.lineTo(w4, h2);
      c.lineTo(w2, h4);
      c.stroke();
    }
    const bhm = h / 2;
    const bwm = w / 2;
    const bh = hasNumber ? (h / 8) : (h - 2 * hb);
    const bw = hasNumber ? (w / 8) : (w - 2 * wb);
    if (hasNumber) {
      if (open) {
        c.moveTo(w2 - wb, hb);
        c.lineTo(w2 + wb, hb);
        c.stroke();
      }
      if (closed) {
        c.moveTo(w2 - wb, h - hb);
        c.lineTo(w2 + wb, h - hb);
        c.stroke();
      }
    } else {
      if (open) {
        c.moveTo(wb, h - hb - bh);
        c.lineTo(wb, h - hb - bhm);
        c.bezierCurveTo(wb, h - hb, wb, h - hb, wb + bwm, h - hb);
        c.lineTo(wb + bw, h - hb);
        c.stroke();
      }
      if (closed) {
        c.moveTo(w - wb - bw, hb);
        c.lineTo(w - wb - bwm, hb);
        c.bezierCurveTo(w - wb, hb, w - wb, hb, w - wb, hb + bhm);
        c.lineTo(w - wb, hb + bh);
        c.stroke();
      }
    }
  }
}
