set compile_env: 0
! ------------------- Class definition for StdOutPrinter
expectvalue /Class
doit
Object subclass: 'StdOutPrinter'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: Globals
  options: #()

%
! ------------------- Remove existing behavior from StdOutPrinter
expectvalue /Metaclass3
doit
StdOutPrinter removeAllMethods.
StdOutPrinter class removeAllMethods.
%
set compile_env: 0
! ------------------- Class methods for StdOutPrinter
category: 'printing'
classmethod: StdOutPrinter
printError: aBlock

  self printLine: [:s |
    s << Character esc << '[1m'.
    s << Character esc << '[31m'.
    aBlock value: s.
    s << Character esc << '[0m'
  ].
%
category: 'printing'
classmethod: StdOutPrinter
printInfo: aBlock

  self printLine: [:s |
    s << Character esc << '[1m'.
    s << Character esc << '[34m'.
    aBlock value: s.
    s << Character esc << '[0m'
  ].
%
category: 'printing'
classmethod: StdOutPrinter
printLine: aBlock

  aBlock value: GsFile stdout.
  GsFile stdout lf; flush
%
category: 'printing'
classmethod: StdOutPrinter
printSuccess: aBlock

  self printLine: [:s |
    s << Character esc << '[1m'.
    s << Character esc << '[32m'.
    aBlock value: s.
    s << Character esc << '[0m'
  ].
%
category: 'printing'
classmethod: StdOutPrinter
printWarning: aBlock

  self printLine: [:s |
    s << Character esc << '[1m'.
    s << Character esc << '[33m'.
    aBlock value: s.
    s << Character esc << '[0m'
  ].
%
! ------------------- Instance methods for StdOutPrinter
