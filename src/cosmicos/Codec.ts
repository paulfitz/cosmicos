import {Statement} from './Statement';

export interface Codec {
  encode(src: Statement): boolean;
  decode(src: Statement): boolean;
}
