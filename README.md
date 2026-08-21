# hyphe-tools

## Loading

Everything in this repository loads through one umbrella baseline —
`BaselineOfHypheTools`. It declares three named groups, so you can load only
what you need instead of the whole thing.

| Group | What it includes |
|---|---|
| `inference` | The three type-inference tools: `Hyphe-TypeModel`, `Hyphe-ReturnTypeAST` (ARTI), `Hyphe-ReturnTypeHeuristic` (ARTH), `Hyphe-ReturnTypeConstraint` (CTI, including its Spec2 UI) — with tests |
| `analysis` | The analysis tools: `Hyphe-Analysis` (code counters + type-prediction calibration), `Hyphe-CFG` (control-flow graph construction and visualization), `Hyphe-ReturnTypeAST-Analysis` (statistics over ARTI's results) — with tests |
| `all` | `inference` + `analysis` together (this is also the `default` group) |

External dependencies (`NeoCSV`, `MethodProxies`) are declared in the
baseline itself and get pulled in automatically — no need to load them
separately.

### Everything (`all`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('all').
```

### Only the type-inference tools (`inference`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('inference').
```

### Only the analysis tools (`analysis`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('analysis').
```

### Loading a single tool directly

Each tool (and `Hyphe-TypeModel`) can also be loaded on its own, through its
own baseline, without the rest:

```smalltalk
"ARTI"
Metacello new
    baseline: 'HypheReturnTypeAST';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').

"ARTH"
Metacello new
    baseline: 'HypheReturnTypeHeuristic';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').

"CTI (without the Spec2 UI)"
Metacello new
    baseline: 'HypheReturnTypeConstraint';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').

"CTI with the UI"
Metacello new
    baseline: 'HypheReturnTypeConstraint';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('All').

"Hyphe-CFG"
Metacello new
    baseline: 'HypheCFG';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').

"Hyphe-Analysis"
Metacello new
    baseline: 'HypheAnalysis';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').
```
