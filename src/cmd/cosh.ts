import {Eval} from './Eval';

const evaluator = new Eval();

function cosmicosEval(input: string, context: unknown, filename: string,
                      callback: (x: null, y: any) => void) {
  const result = evaluator.apply(input);
  if (result !== undefined) {
    callback(null, result);
  }
}

const args = process.argv.slice(2);

if (args.length == 0) {
  console.log("Welcome to a CosmicOS test console, \"help\" and \"examples\" available");
  const repl = require('repl');
  repl.start({
    prompt: "cosmicos> ",
    input: process.stdin,
    output: process.stdout,
    eval: cosmicosEval
  });
} else if (args[0] == "-c") {
  console.log(evaluator.apply(args[1]));
} else {
  console.error("huh?");
}
