export interface UnlessGridExample {
  name: string;
  code: string;
  sequence: Array<number | {[key: string]: boolean}>;
};

const dstep = 20;
const start = -1;

export const D_LATCH: UnlessGridExample = {
  name: 'd',
  code: "12 1 1 0 \n" +
    "14 1 1 0 \n" +
    "1 2 0 1 DATA \n" +
    "3 2 0 1 \n" +
    "5 2 0 1 \n" +
    "7 2 0 1 \n" +
    "9 2 0 1 \n" +
    "11 2 0 1 \n" +
    "12 3 1 0 \n" +
    "14 3 1 0 \n" +
    "11 4 0 1 \n" +
    "13 4 0 1 \n" +
    "10 5 -1 0 \n" +
    "14 5 1 0 \n" +
    "1 6 0 1 ENABLE \n" +
    "3 6 0 1 \n" +
    "5 6 0 1 \n" +
    "7 6 0 1 \n" +
    "9 6 0 1 \n" +
    "11 6 0 1 \n" +
    "12 7 1 0 \n" +
    "14 7 1 0 \n" +
    "11 8 0 1 \n" +
    "13 8 0 1 \n" +
    "10 9 -1 0 \n" +
    "14 9 1 0 \n" +
    "11 10 0 -1 \n" +
    "13 10 0 -1 \n" +
    "15 10 0 -1 \n" +
    "12 11 1 0 \n" +
    "13 12 0 1 \n" +
    "15 12 0 1 \n" +
    "17 12 0 1 \n" +
    "19 12 0 1 OUT \n",
  sequence: [
    {DATA: true, ENABLE: true},
    10,
    start,
    {DATA: false, ENABLE: true},
    dstep,
    {DATA: true},
    dstep,
    {ENABLE: false},
    dstep,
    {DATA: false},
    dstep,
    {DATA: true},
    dstep,
    {DATA: false},
    dstep,
    {ENABLE: true},
    dstep,
    {DATA: true},
    dstep,
  ]
};

export const NOT_GATE: UnlessGridExample = {
  name: 'not',
  code: "8 5 1 0\n" +
    "1 6 0 1 IN\n" +
    "3 6 0 1\n" +
    "5 6 0 1\n" +
    "7 6 0 1\n" +
    "13 6 0 1\n" +
    "15 6 0 1\n" +
    "17 6 0 1\n" +
    "19 6 0 1\n" +
    "8 7 1 0\n" +
    "12 7 -1 0\n" +
    "9 8 0 1\n" +
    "11 8 0 1\n",
  sequence: [
    {IN: true},
    10,
    start,
    {IN: false},
    10,
    {IN: true},
    10,
  ],
};

export const AND_GATE: UnlessGridExample = {
  name: 'and',
  code: "1 2 0 1 IN1\n" +
    "3 2 0 1\n" +
    "4 3 1 0\n" +
    "10 3 1 0\n" +
    "3 4 0 1\n" +
    "5 4 0 1\n" +
    "7 4 0 1\n" +
    "9 4 0 1\n" +
    "10 5 1 0\n" +
    "3 6 0 1\n" +
    "5 6 0 1\n" +
    "7 6 0 1\n" +
    "9 6 0 1\n" +
    "4 7 -1 0\n" +
    "10 7 1 0\n" +
    "1 8 0 1 IN2\n" +
    "3 8 0 1\n" +
    "11 8 0 1\n" +
    "13 8 0 1\n" +
    "15 8 0 1\n" +
    "17 8 0 1\n",
  sequence: [
    {IN1: true, IN2: true},
    10,
    start,
    {IN1: false, IN2: true},
    dstep,
    {IN2: false},
    dstep,
    {IN1: true},
    dstep,
    {IN2: true},
    dstep,
  ]
};

export const OR_GATE: UnlessGridExample = {
  name: 'or',
  code: "10 3 1 0\n" +
    "3 4 0 1 IN1\n" +
    "5 4 0 1\n" +
    "7 4 0 1\n" +
    "9 4 0 1\n" +
    "10 5 1 0\n" +
    "3 6 0 1 IN2\n" +
    "5 6 0 1\n" +
    "7 6 0 1\n" +
    "9 6 0 1\n" +
    "10 7 1 0\n" +
    "9 8 0 1\n" +
    "11 8 0 1\n" +
    "13 8 0 1\n" +
    "15 8 0 1\n" +
    "17 8 0 1\n",
  sequence: [
    {IN1: true, IN2: true},
    10,
    start,
    {IN1: false, IN2: true},
    dstep,
    {IN2: false},
    dstep,
    {IN1: true},
    dstep,
    {IN2: true},
    dstep,
  ]
};

export const NOR_GATE: UnlessGridExample = {
  name: 'nor',
  code: "8 5 1 0\n" +
    "1 6 0 1 IN1\n" +
    "3 6 0 1\n" +
    "5 6 0 1\n" +
    "7 6 0 1\n" +
    "8 7 1 0\n" +
    "1 8 0 1 IN2\n" +
    "3 8 0 1\n" +
    "5 8 0 1\n" +
    "7 8 0 1\n" +
    "8 9 1 0\n" +
    "9 10 0 1\n" +
    "11 10 0 1\n" +
    "13 10 0 1\n" +
    "15 10 0 1\n" +
    "17 10 0 1\n" +
    "19 10 0 1\n",
  sequence: [
    {IN1: true, IN2: true},
    10,
    start,
    {IN1: false, IN2: true},
    dstep,
    {IN2: false},
    dstep,
    {IN1: true},
    dstep,
    {IN2: true},
    dstep,
  ]
};

export const OSCILLATOR: UnlessGridExample = {
  name: 'osc',
  code: "9 6 0 -1\n" +
    "11 6 0 -1\n" +
    "8 7 1 0\n" +
    "12 7 -1 0\n" +
    "5 8 0 1\n" +
    "7 8 0 1\n" +
    "9 8 0 1\n" +
    "11 8 0 1\n" +
    "13 8 0 1\n" +
    "15 8 0 1\n",
  sequence: [
    start,
    12
  ]
};

export const SR_LATCH: UnlessGridExample = {
  name: 'sr',
  code: "1 2 0 1 SET\n" +
    "3 2 0 1\n" +
    "5 2 0 1\n" +
    "7 2 0 1\n" +
    "9 2 0 1\n" +
    "11 2 0 1\n" +
    "13 2 0 1\n" +
    "14 3 1 0\n" +
    "9 4 0 -1\n" +
    "11 4 0 -1\n" +
    "13 4 0 -1\n" +
    "15 4 0 -1\n" +
    "8 5 1 0\n" +
    "12 5 -1 0\n" +
    "5 6 0 1\n" +
    "7 6 0 1\n" +
    "9 6 0 1\n" +
    "11 6 0 1\n" +
    "6 7 -1 0\n" +
    "10 7 1 0\n" +
    "1 8 0 1 RESET\n" +
    "3 8 0 1\n" +
    "5 8 0 1\n" +
    "11 8 0 1\n" +
    "13 8 0 1\n" +
    "15 8 0 1\n" +
    "17 8 0 1\n" +
    "19 8 0 1\n",
  sequence: [
    {SET: false, RESET: true},
    dstep,
    {SET: false, RESET: false},
    dstep,
    start,
    {SET: true, RESET: false},
    dstep,
    {SET: false},
    dstep,
    {RESET: true},
    dstep,
    {RESET: false},
    dstep,
  ]
};

export const UNLESS_GRID_EXAMPLES = {
  'd': D_LATCH,
  'not': NOT_GATE,
  'and': AND_GATE,
  'or': OR_GATE,
  'nor': NOR_GATE,
  'osc': OSCILLATOR,
  'sr': SR_LATCH,
};

export function getGridExample(name: string): UnlessGridExample {
  return UNLESS_GRID_EXAMPLES[name];
}
