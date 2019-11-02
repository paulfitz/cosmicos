import {Codec} from './Codec';
import {Statement} from './Statement';
import {Vocab} from './Vocab';
import {TextDecoder, TextEncoder} from 'util';

const numberMarker: string = '0';
const symbolMarker: string = '1';

export class FourSymbolCodecV2 implements Codec {
  public constructor(private _vocab: Vocab, private _intString: boolean = false) {
  }

  public encode(src: Statement): boolean {
    const content = src.content;
    src.content = [this.codify(content)];
    return true;
  }
  
  public decode(src: Statement): boolean {
    const txt = src.content[0];
    const result: any[] = [];
    this.nest(txt, 0, result);
    src.content = this.interpret(result);
    const tail = src.content[src.content.length - 1];
    if (Array.isArray(tail) && tail.length === 1) {
      const v = tail[0];
      if (Array.isArray(v) && v.length === 0) {
        src.content.splice(src.content.length - 1);
      }
    }
    const result2: any[] = [];
    this.fold(src.content, 0, result2);
    src.content = result2;
    return true;
  }

  public codify(e: any[]): string {
    const result: string[] = this.codifyInner(e, 0);
    result.push('2233');
    return result.join('');
  }

  public codifyNumber(x: number): string {
    let rem = Math.floor(x);
    const b: string[] = [];
    do {
      b.unshift((rem % 2 != 0) ? '1' : '0');
      rem = Math.floor(rem / 2);
    } while (rem != 0);
    b.unshift('2');
    b.push('3');
    return b.join('');
  }

  public codifyInner(e: any[], level: number, result: string[] = []): string[] {
    let needParen = level > 0;
    let first: number = 0;
    if (e.length > 0) {
      if (e[0] === -1) {
        result.push(`${numberMarker}23`);
        needParen = false;
        first++;
      } else if (e[0] === -2) {
        result.push(`${symbolMarker}23`);
        needParen = false;
        first++;
      }
    }
    if (needParen) { result.push('2'); }
    for (let i = first; i < e.length; i++) {
      const v = e[i];
      if (typeof v === 'object') {
        const ei: any[] = v;
        this.codifyInner(ei, level + 1, result);
      } else if (typeof v === 'string' && (v.charAt(0) < '0' || v.charAt(0) > '9') &&
                 v.charAt(0) !== ':' && v.charAt(0) !== '"') {
        result.push(symbolMarker);
        const parts = v.split(':');
        if (parts.length === 1) {
          result.push(this.codifyNumber(this._vocab.get(v)));
        } else {
          result.push('2');
          for (const part of parts) {
            if (part[0] >= '0' && part[0] <= '9') {
              result.push(numberMarker);
              result.push(this.codifyNumber(parseInt(part, 10)));
            } else {
              result.push(symbolMarker);
              result.push(this.codifyNumber(this._vocab.get(part)));
            }
          }
          result.push('3');
        }
      } else if (typeof v === 'string' && v.charAt(0) === ':') {
        // these are funky old bitstrings
        let alt = v.slice();
        alt = alt.replace(/[:]/g, '1');
        alt = alt.replace(/[.]/g, '0');
        result.push(numberMarker);
        result.push('2');
        result.push(alt);
        result.push('3');
      } else if (typeof v === 'string' && v.charAt(0) === '"') {
        // these are funky utf8-encoded-straight-into-message.
        result.push(numberMarker);
        result.push('2');
        const vCoded = (new TextEncoder()).encode(v);
        for (let c = 0; c < vCoded.length; c++) {
          result.push(vCoded[c].toString(2).padStart(8, '0'));
        }
        result.push('3');
      } else if (typeof v === 'string') {
        result.push(numberMarker);
        result.push(this.codifyNumber(parseInt(v, 10)));
      } else if (typeof v === 'number') {
        result.push(numberMarker);
        result.push(this.codifyNumber(v));
      }
    }
    if (needParen) { result.push('3'); }
    return result;
  }

  // Takes a raw string and recovers nesting.
  public nest(txt: string, at: number, result: any[] = []) {
    const bits: string[] = [];
    while (at < txt.length) {
      const ch = txt.charAt(at);
      at++;
      if (ch !== '1' && ch !== '0' && bits.length) {
        result.push(bits.join(''));
        bits.splice(0);
      }
      if (ch === '2') {
        const part: any[] = [];
        at = this.nest(txt, at, part);
        result.push(part);
      } else if (ch === '3') {
        break;
      } else {
        bits.push(ch);
      }
    }
    return at;
  }

  public interpret(content: any[]): any[] {
    let mode: string = '';
    const result: any[] = [];
    for (let i = 0; i < content.length; i++) {
      const v = content[i];
      if (mode === '') {
        if (Array.isArray(v)) {
          result.push(this.interpret(v));
          continue;
        } else if (v === numberMarker) {
          mode = 'number';
        } else if (v === symbolMarker) {
          mode = 'name';
        }
      } else if (mode === 'name') {
        if (v.length === 0) {
          result.push('$');
        } else {
          result.push(this.interpretName(v as any[]));
        }
        mode = '';
      } else if (mode === 'number') {
        if (v.length === 0) {
          result.push('|');
        } else {
          const q: string = v[0];
          if (q.length >= 20) {
            if (parseInt(q.substr(0, 8), 2) === '"'.charCodeAt(0)) {
              const letters: number[] = [];
              // this is a funky utf8 string encoded verbatim
              for (let c = 0; c < q.length ; c += 8) {
                const letter = parseInt(q.substr(c, 8), 2);
                letters.push(letter);
              }
              result.push((new TextDecoder()).decode(Uint8Array.from(letters)));
            } else {
              let alt = q.slice();
              alt = alt.replace(/[1]/g, ':');
              alt = alt.replace(/[0]/g, '.');
              result.push(alt);
            }
          } else {
            const i = parseInt(v[0], 2);
            if (this._intString) {
              result.push(String(i));
            } else {
              result.push(i);
            }
          }
        }
        mode = '';
      } else {
        result.push(v);
        mode = '';
      }
    }
    return result;
  }

  public interpretName(content: any[]) {
    if (content.length === 1) {
      return this._vocab.reverse(parseInt(content[0], 2));
    }
    const parts: string[] = [];
    for (let i = 0; i < content.length; i += 2) {
      const sym = content[i] === symbolMarker;
      const part: string = content[i+1][0];
      const v = parseInt(part, 2);
      if (sym) {
        parts.push(this._vocab.reverse(v));
      } else {
        parts.push(`${v}`);
      }
    }
    return parts.join(':');
  }

  public fold(content: any[], at: number, result: any[] = []): number {
    let dollar: boolean = false;
    while (at < content.length) {
      const v = content[at];
      at++;
      if (Array.isArray(v)) {
        const part: any[] = [];
        this.fold(v, 0, part);
        result.push(part);
      } else if (v === '$') {
        dollar = true;
      } else if (v === '|') {
        const part: any[] = [-1];
        at = this.fold(content, at, part);
        result.push(part);
      } else {
        if (dollar) {
          result.push([-2, v]);
          dollar = false;  // TODO turn off in other places in case of mis-use
        } else {
          result.push(v);
        }
      }
    }
    return at;
  }
}

