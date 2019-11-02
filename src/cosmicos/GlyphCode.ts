import {FourSymbolCodecV2} from './FourSymbolCodecV2';
import {WideVocab} from './Vocab';

export class GlyphCode {
  private bits: number;
  private top: number;
  private base: number;

  public constructor(flavor: string, private debug: boolean = false) {
    if (flavor !== 'octo') {
      throw new Error('only octo supported now');
    }
    this.bits = 6;
    this.top = Math.floor(Math.pow(2, this.bits));
    this.base = 0xf144;
    this.reset();
  }

  public reset() {
  }

  public addString(txt: string): string {
    const vocab = new WideVocab();
    const codec = new FourSymbolCodecV2(vocab);
    const result: any[] = [];
    codec.nest(txt, 0, result);  // like ["1", ["101010"], "0", ["1", ["1010101"]]]
    const result2: any[] = [];
    this.addList(result, false, false, false, result2);
    return result2.join('');
  }

  public addList(e: any[], block: boolean, needSpace: boolean, isNumber: boolean,
                 result: any[]): boolean {
    if (e.length === 1 && typeof e[0] === 'string') {
      if (needSpace) { this.addSyntax(' ', result); }
      this.addNumber(e[0], isNumber, result);
      return true;
    }
    if (e.length === 0) {
      if (block) {
        if (isNumber) {
          this.addSyntax('|', result);
        } else {
          this.addSyntax('$', result);
        }
      }
      return false;
    }
    let typed: boolean = false;
    for (let i = 0; i < e.length; i++) {
      const v = e[i];
      if (typeof v === 'string') {
        typed = true;
        isNumber = v === '0';
        continue;
      }
      const vlist = v as any[];
      if (typed) {
        needSpace = this.addList(vlist, true, needSpace, isNumber, result) && !block;
      } else {
        if (vlist.length === 1 && Array.isArray(vlist[0]) && vlist[0].length === 0) {
          this.addSyntax(';', result);
        } else {
          this.addSyntax('(', result);
          this.addList(vlist, false, false, false, result);
          this.addSyntax(')', result);
          needSpace = false;
        }
      }
      typed = false;
    }
    return needSpace;
  }

  public addNumber(e: string, isNumber: boolean, result: any[]) {
    const rem = e.length % this.bits;
    let first: boolean = true;
    for (let i = rem === 0 ? 6 : rem; i < e.length + this.bits; i += this.bits) {
      const part = e.substr(Math.max(0, i - this.bits), Math.min(i, this.bits));
      this.addSingleNumber(part, first, isNumber, result);
      first = false;
    }
  }

  public addSyntax(e: '(' | ')' | '|' | '$' | ';' | ' ', result: any[]) {
    if (this.debug) {
      result.push(e);
      return;
    }
    if (e === '(') {
      result.push(this.showChar1(false, false, 0, true, false));
      return;
    } else if (e === ')') {
      result.push(this.showChar1(false, false, 0, false, true));
      return;
    }
    //           01234567
    const idx = "xxxx|$ ;".indexOf(e);
    result.push(this.showChar1(false, false, idx, false, false));
  }

  public addSingleNumber(e: string, first: boolean, isNumber: boolean, result: any[]) {
    if (this.debug) {
      if (first) {
        result.push(isNumber ? 'n' : 's');
      }
      result.push(`[${e}]`);
      return;
    }
    result.push(this.showChar1(!isNumber, true, parseInt(e, 2), false, false));
  }

  public showChar1(sym: boolean, hasNum: boolean, n: number, open: boolean, close: boolean): string {
    var idx: number = 0;
    if (hasNum) {
      idx = (open?1:0);
      idx *= 2;
      idx += (close?1:0);
      idx *= this.top;
      idx += n;
      if (!sym) {
        idx += 3 * this.top;
      }
    } else {
      idx += 2 * 2 * this.top;
      idx += n;
      if (n==0) {
        idx += open ? 2 : 0;
        idx += close ? 1 : 0;
      }
    }
    idx += this.base;
    return "&#x" + idx.toString(16) + ";";
  }

}
