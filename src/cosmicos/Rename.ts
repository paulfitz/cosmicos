
import * as standardNames from '../../msg/names.json';

export class Rename {
  private names = new Map<string, string>();
  private unnames = new Map<string, string>();

  public constructor(pairs: Array<[string, string]> = []) {
    if (pairs.length === 0) {
      pairs = standardNames as any;
    }
    for (const pair of pairs) {
      if (pair[0]) {
        this.add(pair[0], pair[1]);
      }
    }
  }

  public add(src: string, dest: string) {
    this.names.set(src, dest);
    this.unnames.set(dest, src);
  }

  public get(src: string): string {
    if (src.charAt(0) === ':') { return src; }
    if (this.names.has(src)) {
      return this.names.get(src);
    }
    const parts = src.split(':');
    const next = parts.length > 1 ? parts.map(part => this.get(part)).join(':') : src;
    if (next === src) { return next; }
    return this.get(next);
  }

  // this is weak, doesn't deal with parts.
  public unget(src: string): string {
    while (this.unnames.has(src)) {
      src = this.unnames.get(src);
    }
    return src;
  }

  public rename(e: any[]) {
    for (let i = 0; i < e.length; i++) {
      const v = e[i];
      if (Array.isArray(v)) {
        this.rename(v);
        continue;
      }
      if (!(typeof v === 'string')) { continue; }
      e[i] = this.get(e[i]);
    }
    return e;
  }

  public renameWithinString(src: string): string {
    const parts: string[] = [];
    let base: number = 0;
    let prevActive: boolean = false;
    const letter = new RegExp(/[-a-zA-Z0-9.:!]/);
    for (let i = 0; i <= src.length; i++) {
      const active = (i < src.length) ? letter.test(src.charAt(i)) : !prevActive;
      if (active !== prevActive) {
        if (i !== base) {
          const part = src.substr(base, i - base);
          base = i;
          parts.push(prevActive ? this.get(part) : part);
        }
      }
      prevActive = active;
    }
    return parts.join('');
  }

  public unrenameWithinString(src: string): string {
    const parts: string[] = [];
    let base: number = 0;
    let prevActive: boolean = false;
    const letter = new RegExp(/[-a-zA-Z0-9.:!]/);
    for (let i = 0; i <= src.length; i++) {
      const active = (i < src.length) ? letter.test(src.charAt(i)) : !prevActive;
      if (active !== prevActive) {
        if (i !== base) {
          const part = src.substr(base, i - base);
          base = i;
          parts.push(prevActive ? this.unget(part) : part);
        }
      }
      prevActive = active;
    }
    return parts.join('');
  }
}
