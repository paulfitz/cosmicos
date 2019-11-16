const path = require('path');

const variant = process.env.COSMIC_VARIANT;

if (!variant) {
  throw new Error('Need COSMIC_VARIANT');
}

const common = {
  mode: 'development',
  resolve: {
    modules: [`./build/${variant}/js`, `./build/${variant}`]
  }
}

const cosh = {
  ...common,
  entry: `./build/${variant}/js/src/cmd/cosh.js`,
  target: 'node',
  output: {
    path: path.resolve('build', variant, 'bin'),
    filename: 'cosh.js'
  }
};

const libCosmicos = {
  ...common,
  entry: `./build/${variant}/js/src/cmd/Eval.js`,
  target: 'web',
  output: {
    path: path.resolve('build', variant, 'bin'),
    filename: 'lib_cosmicos.js',
    library: 'Eval',
    libraryExport: 'default'
  }
};

module.exports = [ cosh, libCosmicos ];

