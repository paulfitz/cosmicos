export interface Statement {
  content: any[];
}

export class WideStatement implements Statement {
  public constructor(public content: any[]) {
  }
}
