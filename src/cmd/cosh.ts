import Eval from './Eval';

const evaluator = new Eval();
let server: any;

function cosmicosEval(input: string, context: unknown, filename: string,
                      callback: (x: null, y: any) => void) {
  const result = evaluator.apply(input, console.log);
  if (result !== undefined) {
    if (result !== null) {
      callback(null, result);
    } else {
      server.displayPrompt();
    }
  }
}

const args = process.argv.slice(2);

if (args.length == 0) {
  console.log("Welcome to a CosmicOS test console, \"help\" and \"examples\" available");
  const repl = require('repl');
  server = repl.start({
    prompt: "cosmicos> ",
    input: process.stdin,
    output: process.stdout,
    eval: cosmicosEval
  });
} else if (args[0] == "-c") {
  console.log(evaluator.apply(args[1], console.log));
} else {
  console.error("huh?");
}
