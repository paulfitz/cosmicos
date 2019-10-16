import {Canvas, CanvasRenderingContext2D} from 'canvas';
import * as child_process  from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

import {cosmicos as cos} from 'SpiderScrawl';
import {GlyphTool, OctoGlyph} from './OctoGlyph';

const outputDirectory = process.argv[2];

interface Spec {
  open: boolean;
  closed: boolean;
  m: number;
  mSpecial: number;
  hasNumber: boolean;
  tool: GlyphTool;
  settings: ToolSettings;
}

interface ToolSettings {
  tool: GlyphTool;
  name: string;
  bits: number;
  specials: boolean;
}

function getSettings(name: 'octo' | 'spider'): ToolSettings {
  if (name === 'octo') {
    return {
      tool: new OctoGlyph(),
      name: '1_octo',
      bits: 6,
      specials: true
    };
  }
  return {
    tool: new cos.SpiderScrawl(),
    name: '0_spider',
    bits: 4,
    specials: false
  };
}

function addGlyphSpecs(store: Spec[], settings: ToolSettings) {
  const tool = settings.tool;
  // open = 0 or 1, closed = 0 or 1, n = 0...16 inclusive with 16 = no num
  const top = tool.count();
  for (let open=0; open<=1; open++) {
    for (let closed=0; closed<=1; closed++) {
      for (let m=0; m<top; m++) {
        store.push({
          open: Boolean(open),
          closed: Boolean(closed),
          m,
          mSpecial: 0,
          hasNumber: true,
          tool,
          settings,
        });
      }
    }
  }
  let mSpecial: number = 0;
  for (let open=0; open<=1; open++) {
    for (let closed=0; closed<=1; closed++) {
      store.push({open: Boolean(open), closed: Boolean(closed), m: 0, mSpecial, hasNumber: false, tool, settings});
      mSpecial++;
    }
  }
  if (settings.specials) {
    for (let m = 4; m <= 7; m++) {
      store.push({open: false, closed: false, m, mSpecial: m,
                  hasNumber: false, tool, settings});
    }
  }
}


async function processGlyph(t: Spec) {
  return new Promise(resolve => {
    const {open, closed, m, hasNumber, tool} = t;
    console.log(`Working on ${hasNumber} ${m} ${open} ${closed}`);
    const w = t.tool.defaultWidth();
    const h = t.tool.defaultHeight();
    const canvas = new Canvas(w,h);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#fff';
    ctx.fillRect(0,0,w,h);
    ctx.lineWidth = 3;
    ctx.strokeStyle = '#000';
    tool.attach(ctx, w, h);
    tool.showChar(hasNumber, m, open, closed);
    let code = t.settings.name + "_";

    const d = t.settings.bits;
    if (t.hasNumber) {
      code += "" + (open ? 1 : 0) + (closed ? 1 : 0);
      code += ("0000000000" + m.toString(2)).slice(-d);
    } else {
      // m should be between 0 and 9
      code += "22" + ("_________" + t.mSpecial).slice(-d);
    }
    const fname = path.resolve(outputDirectory, 'icons', 'spider', 'coschar_' + code + ".png");
    const out = fs.createWriteStream(fname);
    const stream = canvas.createPNGStream();
    stream.on('data', function(chunk){
      out.write(chunk);
    });
    stream.on('end', function(){
      out.end(() => {
        console.log('saved png ' + fname);
        resolve();
      });
    });
  });
}

function finalizeGlyph() {
  console.log("Spawning...");
  child_process.spawnSync(path.resolve(__dirname, "glyphs_to_svg.sh"),
                          [path.resolve(outputDirectory, 'icons', 'spider'),
                           path.resolve(outputDirectory, 'fonts', 'spider')],
                          {stdio: [0, 1, 2]});
  console.log("Spawned...");
}

async function main() {
  const todo: Spec[] = [];
  addGlyphSpecs(todo, getSettings('spider'));
  addGlyphSpecs(todo, getSettings('octo'));
  for (const t of todo) {
    await processGlyph(t);
  }
  finalizeGlyph();
}

main().catch(console.error);
