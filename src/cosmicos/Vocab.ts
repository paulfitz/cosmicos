export interface Vocab {
  get(name: string): number;
  reverse(id: number): string;
  use(name: string): void;
}

export class WideVocab implements Vocab {
  private nameToCode = new Map<string, number>();
  private codeToName = new Map<number, string>();
  private used = new Set<string>();
  private nextId: number = 1;

  public get(name: string): number {
    if (!this.nameToCode.has(name)) {
      while (this.codeToName.has(this.nextId)) {
        this.nextId++;
      }
      this.nameToCode.set(name, this.nextId);
      this.codeToName.set(this.nextId, name);
      this.nextId++;
    }
    return this.nameToCode.get(name)!;
  }

  public use(name: string): void {
    this.used.add(name);
  }

  public reverse(id: number): string {
    return this.codeToName.get(id) || `_${id}`;
  }
  
  public set(name: string, id: number): number {
    this.nameToCode.set(name, id);
    this.codeToName.set(id, name);
    return id;
  }
}
