import {FourSymbolCodecV2} from '../src/cosmicos/FourSymbolCodecV2';
import {GlyphCode} from '../src/cosmicos/GlyphCode';
import {Rename} from '../src/cosmicos/Rename';
import {WideStatement} from '../src/cosmicos/Statement';
import {WideVocab} from '../src/cosmicos/Vocab';

describe('four symbol encoding', function() {
  it('roundtrip', function() {
    const examples = [
      [1, 14, [2, 33, "hello", "hello:there:12"], 3],
      [1, 14, [10, [-1, 3, 5]], [-2, "hello"]],
      ["is:int", [-1, "unary", "0", "zig:22:there"]]
    ];
    for (const example of examples) {
      const statement = new WideStatement(example);
      console.log(JSON.stringify(statement));
      const vocab = new WideVocab();
      vocab.set("there", 42);
      vocab.set("zig", 0b10110110);
      const x = new FourSymbolCodecV2(vocab, true);
      x.encode(statement);
      console.log(JSON.stringify(statement));
      const gc = new GlyphCode('octo');
      console.log(gc.addString(statement.content[0]));
      x.decode(statement);
      console.log(JSON.stringify(statement));
    }
  });

  it('renaming', function() {
    const rename = new Rename();
    rename.add('hello', 'hi');
    console.log(rename.get('test'));
    console.log(rename.get('hello'));
    console.log(rename.get('hello:test'));
    console.log(rename.rename(['test', 1, 2, ['test', 'hello', '1:hello:2']]));
    console.log(rename.renameWithinString('1 2 hello hello:there (3 4 hello there)\n hello;'));
    rename.add('make-cell', 'cell:make');
    console.log(rename.renameWithinString('@ demo:make-cell:x | make-cell 14;'));
  });
});
