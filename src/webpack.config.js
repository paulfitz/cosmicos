const path = require('path');

const variant = process.env.COSMIC_VARIANT;

if (!variant) {
  throw new Error('Need COSMIC_VARIANT');
}

const common = {
  mode: 'development',
  target: 'node',
  resolve: {
    modules: [`./build/${variant}/js`, `./build/${variant}`]
  }
}

const cosh = {
  ...common,
  entry: `./build/${variant}/js/src/cmd/cosh.js`,
  output: {
    path: path.resolve('.', 'build', variant, 'bin'),
    filename: 'cosh.js'
  }
};

module.exports = [ cosh ];

