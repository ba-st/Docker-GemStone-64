#!/usr/bin/env bash

set -e

readonly PROJECT_NAME=$1
readonly SYSTEM_USER_PASSWORD="${GS64_CI_SYSTEM_USER_PASSWORD:-swordfish}"

echo "Running ${PROJECT_NAME} tests..."

topaz -i -q <<EOF >> /dev/null
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
input StdOutPrinter.gs
commit
logout
exit 0
EOF

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/running-tests.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
expectvalue true
doit
| suite result sortBlock currentTestClass |

suite := (Rowan projectNamed: '${PROJECT_NAME}') testSuite.

StdOutPrinter printLine: [:s |
  s << 'Running suite ' << suite name << ' with ' << suite tests size asString << ' tests.'.
].

result := suite run.

StdOutPrinter
  printLine: [:s | s << '.............'];
  printLine: [:s | s << 'Finished running suite: ' << suite name ];
  printLine: [:s | ];
  printInfo: [:s | s << '##################################################'];
  printInfo: [:s | s << ' ' << suite name];
  printInfo: [:s | s << ' ' << result runCount asString << ' tests with ' << result failureCount asString << ' failures and ' << result errorCount asString << ' errors.' ];
  printInfo: [:s | s << '##################################################'].

sortBlock :=  [:a :b | a class name < b class name or: [a class name = b class name and: [ a selector < b selector ]]].

StdOutPrinter
  printLine: [:s | ];
  printSuccess: [:s | s << '(' << result passedCount asString << ' tests passed)' ].

(result passed sort: sortBlock)
  do: [:test | 
    currentTestClass = test class name
      ifFalse: [ 
        currentTestClass := test class name.
        StdOutPrinter
          printLine: [:s | ];
          printLine: [:s | s << currentTestClass asString ]
      ].
    StdOutPrinter printSuccess: [:s | s << ' ✓ ' << test selector asString ]
  ].

StdOutPrinter
  printLine: [:s | ];
  printWarning: [:s | s << '##########################'];
  printWarning: [:s | s << ' ' << result failureCount asString << ' tests failed' ];
  printWarning: [:s | s << '##########################'].

(result failures sort: sortBlock)
  do: [:test | 
    currentTestClass = test class name
      ifFalse: [ 
        currentTestClass := test class name.
        StdOutPrinter
          printLine: [:s | ];
          printLine: [:s | s << currentTestClass asString ]
      ].
    StdOutPrinter printWarning: [:s | s << ' ✗ ' << test selector asString ]
  ].

StdOutPrinter
  printLine: [:s | ];
  printError: [:s | s << '##########################'];
  printError: [:s | s << ' ' << result errorCount asString << ' tests errored' ];
  printError: [:s | s << '##########################'].

(result errors sort: sortBlock)
  do: [:test | 
    currentTestClass = test class name
      ifFalse: [ 
        currentTestClass := test class name.
        StdOutPrinter
          printLine: [:s | ];
          printLine: [:s | s << currentTestClass asString ]
      ].
    StdOutPrinter printError: [:s | s << ' ✗ ' << test selector asString ]
  ].

result hasPassed ifTrue: [
    StdOutPrinter
      printLine: [:s | ];
      printSuccess: [:s | s << '#####################################################'];
      printSuccess: [:s | s << '✓ Executed ' << result runCount asString << ' tests with ' << result failureCount asString << ' failures and ' << result errorCount asString << ' errors.' ];
      printSuccess: [:s | s << '#####################################################']
  ] ifFalse: [
      StdOutPrinter
      printLine: [:s | ];
      printError: [:s | s << '#####################################################'];
      printError: [:s | s << '✗ Executed ' << result runCount asString << ' tests with ' << result failureCount asString << ' failures and ' << result errorCount asString << ' errors.' ];
      printError: [:s | s << '#####################################################']
  ].
result hasPassed
%
commit
logout
exit 0
EOF

echo "Running ${PROJECT_NAME} tests... [FINISHED]"
