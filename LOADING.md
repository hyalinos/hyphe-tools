# Загрузка hyphe-tools

Всё содержимое репозитория загружается через один зонтичный бейзлайн —
`BaselineOfHypheTools`. Он объявляет три именованные группы, которые можно
запрашивать по отдельности, не подгружая лишнего.

| Группа | Что входит |
|---|---|
| `inference` | Три инструмента вывода типов: `Hyphe-TypeModel`, `Hyphe-ReturnTypeAST` (ARTI), `Hyphe-ReturnTypeHeuristic` (ARTH), `Hyphe-ReturnTypeConstraint` (CTI, включая Spec2-UI) — с тестами |
| `analysis` | Инструменты анализа: `Hyphe-Analysis` (счётчики кода + калибровка типов), `Hyphe-CFG` (построение и визуализация графа потока управления), `Hyphe-ReturnTypeAST-Analysis` (статистика по результатам ARTI) — с тестами |
| `all` | `inference` + `analysis` вместе (это же группа `default`) |

Внешние зависимости (`NeoCSV`, `MethodProxies`) объявлены прямо в бейзлайне и
подтягиваются автоматически — отдельно их загружать не нужно.

## Всё сразу (`all`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('all').
```

## Только инструменты вывода типов (`inference`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('inference').
```

## Только инструменты анализа (`analysis`)

```smalltalk
Metacello new
    baseline: 'HypheTools';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('analysis').
```

## Загрузка конкретного инструмента напрямую

Каждый инструмент (и `Hyphe-TypeModel`) также может грузиться сам по себе,
своим собственным бейзлайном, без остальных:

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

"CTI (без Spec2-UI)"
Metacello new
    baseline: 'HypheReturnTypeConstraint';
    repository: 'github://hyalinos/hyphe-tools/src';
    load: #('Core').

"CTI с UI"
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
