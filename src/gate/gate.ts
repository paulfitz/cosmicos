import {draw, DrawOptions} from './UnlessDraw';
import {UnlessGrid} from './UnlessGrid';
import {getGridExample} from './UnlessGridExamples';
import {Canvas} from 'canvas';
import * as child_process from 'child_process';
import * as fse from 'fs-extra';

async function saveImage(canvas: Canvas, fname: string) {
  // TODO: error-handling
  return new Promise((resolve) => {
    const out = fse.createWriteStream(fname);
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

function applyStep(grid: UnlessGrid, step: number|{[key: string]: boolean}): number {
  if (typeof step === 'number') {
    return step;
  }
  for (const key of Object.keys(step)) {
    const val = step[key];
    grid.force(key, val);
  }
  return 0;
}

async function makeImages(name: string, dir: string) {
  const sc = 15;
  const network = getGridExample(name);
  const grid = new UnlessGrid(network.code);
  const [x0, y0, x1, y1] = grid.getBounds();
  console.log(x0, y0, x1, y1);
  const w = (x1 - x0 + 2) * sc + 2 * sc;
  const h = (y1 - y0 + 2) * sc + 2 * sc;
  const dx = - x0 * sc + sc;
  const dy = - y0 * sc + sc;
  var canvas = new Canvas(w, h);
  const options: DrawOptions = {
    scale: sc,
    xOffset: dx,
    yOffset: dy,
    showLabels: false,
  };

  let at: number = 0;
  const fnames: string[] = [];
  let active: boolean = false;
  for (const act of network.sequence) {
    const steps = applyStep(grid, act);
    if (steps === -1) { active = true; }
    for (let i = 0; i < steps; i++) {
      if (active) {
        draw(canvas, grid, options);
        const fname = `${dir}/${100000 + at}.png`;
        await saveImage(canvas, fname);
        fnames.push(fname);
        at++;
      }
      grid.update();
    }
  }
  return fnames;
}

async function main(name: string) {
  name = name || 'd';
  const dir = '/tmp/zig';
  await fse.remove(dir);
  await fse.mkdirp(dir);
  const fnames = await makeImages(name, dir);
  const args = ['-delay', '10', ...fnames, `${name}.gif`];
  console.log("convert", args);
  child_process.execFileSync('convert', args);
  console.log("made", `${name}.gif`);
}

main(process.argv[2]).catch(err => {
  console.log("Failure:", err);
});
