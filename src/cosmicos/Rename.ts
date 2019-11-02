export class Rename {
  private names = new Map<string, string>();

  public constructor(pairs: Array<[string, string]> = []) {
    for (const pair of pairs) {
      if (pair[0]) {
        this.add(pair[0], pair[1]);
      }
    }
  }

  public add(src: string, dest: string) {
    this.names.set(src, dest);
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
}
