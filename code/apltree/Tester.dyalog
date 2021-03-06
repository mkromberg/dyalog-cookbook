﻿:Class Tester
⍝ This class establishes a test framework for APL applications. This help
⍝ is **not** an introduction into how the test framework works, and
⍝ how you should organize your test cases. More information is available
⍝ from the Tester's home page on the APL Wiki: <http://aplwiki.com/Tester>.\\
⍝ Note that the namespace hosting the test cases **must** be an ordinary
⍝ named namepsace. In other words, it can be neither an unnamed namespace
⍝ or a scripted namepsae.\\
⍝ These are the `Run*` functions you may call:
⍝ * `Run`
⍝ * `RunBatchTests`
⍝ * `RunBatchTestsInDebugMode`
⍝ * `RunDebug`
⍝ * `RunThese`
⍝
⍝ All `Run*` functions return a two-element vector as result:
⍝ 1. Is a return code which has one of three values:
⍝    * 0 means all executed, all okay.
⍝    * 1 means that some test cases failed or crashed.
⍝    * 2 means that at least one test case has not been executed but those that were
⍝      executed passed. Reasons for not being executed can be, among others, that a
⍝      test case is inactive or cannot run on the current platform.
⍝ 2. A vector of text vectors. For every test function there is one item added to
⍝    this vector. In addition there is a summary at the end of the vector, reporting
⍝    how many test cases got executed, how many failed/broke or were not executed
⍝    and for what reason.
⍝
⍝ ## Details
⍝ All methods take a right argument which is a ref pointing to an ordinary
⍝ namespace hosting the test functions. What is a test function and what is
⍝ not is determined by naming convention: they must start with the string
⍝ `Test_` (case sensitive!) followed by digits. Therefore these
⍝ are all valid names for test functions:
⍝ * `Test_1`
⍝ * `Test_001`
⍝ * `TEST_9999`
⍝
⍝ In order to allow grouping when more complex test cases are needed
⍝ the following names are valid as well:
⍝ * `Test_GroupA_001`
⍝ * `Test_GroupB_002`
⍝
⍝ Note that there must be a second `_` character (but no more!) to define
⍝ the group. **After** the second underscore only digits are allowed.
⍝
⍝ ## Comments in line 1
⍝ Line 1 of a test function must contain information that allow a user to identify
⍝ what this particular test is all about. The `L` (for "List) function (one
⍝ of the [Helpers](#) - see there) lists all test functions with their names
⍝ and this single comment line. Also all `Run*` function list this first line.
⍝
⍝ ## The right argument
⍝ All test functions must accept a right argument of length two:
⍝
⍝ ### [1] batchFlag
⍝ Use this to avoid running test cases that depend on a human beeing in front
⍝ of the monitor so that questions can be asked.
⍝
⍝ ### [2] Stop flag
⍝ Setting this to 1 prevents errors from being trapped, so you can
⍝ investigate failing test cases straight away.
⍝
⍝ ## Result of a test function
⍝ Test functions must return a result. This is expected to be a single integer.
⍝ However, you don't need to worry about those integers; instead use one of the
⍝ niladic functions established as [Helpers](#) in your test namespace.\\
⍝ These are the names of those functions and their meaning:
⍝
⍝ | `∆OK`                | Passed
⍝ | `∆Failed`            | Unexpected result
⍝ | `∆NoBatchTest`       | Not executed because `batchFlag` was 1.
⍝ | `∆InActive`          | Not executed because the test case is inactive (not ready, buggy, whatever)
⍝ | `∆WindowsOnly`       | Not executed because runs under Windows only.
⍝ | `∆LinuxOnly`         | Not executed because runs under Linux only.
⍝ | `∆MacOnly`           | Not executed because runs under Mac OS only.
⍝ | `∆LinuxOrMacOnly`    | Not executed because runs Linux/Mac OS only.
⍝ | `∆LinuxOrWindowsOnly`| Not executed because runs Linux/Windows only.
⍝ | `∆MacOrWindowsOnly`  | Not executed because runs Mac OS/Windows only.
⍝ | `∆NoAcreTests`       | No acre-related testsa are executed.
⍝
⍝ Using the functions rather than numeric constants does not only improve readability
⍝ but makes searching easier as well.
⍝
⍝ ## "Initial" function
⍝ If a function `Initial` exists in the namespace containing the test cases
⍝ it is executed automatically before any test case is executed.\\
⍝ Note that such a function must be either niladic or monadic. If it is
⍝ monadic a reference pointing to the parameter space will be passed as
⍝ right argument. That allows you to, say, check the parameters.
⍝ Use this to initialise an environment all your test cases need.
⍝
⍝ ## "Cleanup" function
⍝ If a function `Cleanup` exists in the namespace containing the test cases
⍝ it is executed automatically after the test cases have been executed.\\
⍝ Use this to clean up any leftovers.\\
⍝ It might be a good idea to call this in line 1 of `Initial`.
⍝
⍝ ## INI files
⍝ When running any of the `Run*` methods they check for INI files in the current
⍝ directory:
⍝ * First it tries to find "testcase\_{computername}.ini"
⍝ * If no such file exists it tries to find "testcase.ini"
⍝
⍝ If one of those files exist a namespace `Ini` is created within the
⍝ namespace where your test cases live. This namespace is populated by the
⍝ contents of the INI file found.\\
⍝ After executing the test cases this namespace is deleted.
⍝
⍝ ## Helpers
⍝ There are a several functions called helpers you might find useful when creating test
⍝ cases. The method `EstablishHelpersIn` takes a ref pointing to the namespace
⍝ hosting the test cases (defaults to `↑⎕RSI` when empty). It copies those helpers
⍝ into the hosting namespace. The explicit result is a list of all helpers.\\
⍝ One of the helpers lists all helpers; execute
⍝ ~~~
⍝       #.TestCases.ListHelpers
⍝ Run                       Run all test cases
⍝ RunDebug                  Run all test cases with DEBUG flag on
⍝ RunThese                  Run just the specified tests.
⍝ RunBatchTests             Run all batch tests
⍝ RunBatchTestsInDebugMode  Run all batch tests in debug mode (no error trapping) and with stopFlag←1.
⍝ E                         Get all functions into the editor starting their names with "Test_".
⍝ L                         Prints a list with all test cases and the first comment line to the session.
⍝ G                         Prints all groups to the session.
⍝ FailsIf                   Usage : →FailsIf x, where x is a boolean scalar
⍝ PassesIf                  Usage : →PassesIf x, where x is a boolean scalar
⍝ GoToTidyUp                Returns either an empty vector or "Label" which defaults to ∆TidyUp
⍝ RenameTestFnsTo           Renames a test function and tell acre.
⍝ ListHelpers               Lists all helpers available from the `Tester` class.
⍝ ∆OK                       Constant; used as result of a test function
⍝ ∆Failed                   Constant; used as result of a test function
⍝ ∆NoBatchTest              Constant; used as result of a test function
⍝ ∆Inactive                 Constant; used as result of a test function
⍝ ∆NoAcreTests              Constant; used as result of a test function
⍝ ∆WindowsOnly              Constant; used as result of a test function
⍝ ∆LinuxOnly                Constant; used as result of a test function
⍝ ∆MacOnly                  Constant; used as result of a test function
⍝ ∆LinuxOrMacOnly           Constant; used as result of a test function
⍝ ∆LinuxOrWindowsOnly       Constant; used as result of a test function
⍝ ∆MacOrWindowsOnly         Constant; used as result of a test function
⍝ ~~~
⍝ for this.\\
⍝ ## Misc
⍝ This class is part of the APLTree Open Source project.\\
⍝ Home page: <http://aplwiki.com/Tester>\\
⍝ Kai Jaeger ⋄ APL Team Ltd

    ⎕IO←1 ⋄ ⎕ML←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      ⍝ * 3.0.0
      ⍝   * `Initial` may return a Boolean result. 0 means it could not initialize.
      ⍝   * When `EstablishHelpersIn` or any of the `Run*` functions is executed the hosting
      ⍝     namespace is checked for being an ordinary named namespace.
      ⍝   * Bug fixes
      ⍝     * `Run` should have returned a Boolean flag and a report. Prior to 3.0 is return
      ⍝       just the report.
      ⍝ * 2.9.1
      ⍝   * Documentation corrected regarding INI files.
      ⍝ * 2.9.0
      ⍝   * Additional method `RunBatchTestsInDebugMode` (helper) introduced.
      ⍝   * Additional constant `∆NoAcreTests`
      ⍝ * 2.8.1
      ⍝   * Some missing constants added.
      ⍝   * Typo fixed.
      ⍝ * 2.8.0
      ⍝   * Some of the `Run*` methods now accept a partly named qualifier as long as
      ⍝     what's provided is good enough to actually qualify a group.
      ⍝   * The `Run*` functions now check whether `⎕TRAP` is localized in all test
      ⍝     functions and print a warning to the session except in batch mode.
      r←(Last⍕⎕THIS)'3.0.0' '2017-01-14'
    ∇

    ∇ {(rc log)}←Run refToTestNamespace;flags
    ⍝ Runs all test cases in `refToTestNamespace` with error trapping. Broken
    ⍝ as well as failing tests are reported in the session as such but they
    ⍝ don't stop the program from carrying on.
      :Access Public Shared
      flags←1 0 0 0
      (rc log)←refToTestNamespace Run__ flags,⊂⍬
    ∇

    ∇ {(rc log)}←{trapAndDebugFlag}RunBatchTests refToTestNamespace;flags
    ⍝ Runs all test cases in `refToTestNamespace` but tells the test functions
    ⍝ that this is a batch run meaning that test cases in need for any human
    ⍝ being for interaction should quit silently.\\
    ⍝ Returns 0 for okay or a 1 in case one or more test cases are broken or failed.\\
    ⍝ This method can run in a runtime as well as in an automated test environment.\\
    ⍝ The left argument defaults to 0 but can be set to 1. It sets both, `stopFlag`\\
    ⍝ and `trapFlag` when specified. It can be a scalar or a two-item vector.
      :Access Public Shared
      trapAndDebugFlag←{(0<⎕NC ⍵):⍎⍵ ⋄ 1 0}'trapAndDebugFlag'
      flags←(1↑trapAndDebugFlag),(¯1↑trapAndDebugFlag),1 0
      (rc log)←refToTestNamespace Run__ flags,⊂⍬
    ∇

    ∇ {log}←{x}RunDebug refToTestNamespace;flags;rc;stopAt;stop
    ⍝ Runs all test cases in `refToTestNamespace` **without** error trapping.
    ⍝ If a test case encounters an invalid result it stops. Use this function
    ⍝ to investigate the details after `Run` detected a problem.\\
    ⍝ This will work only if you use a particualar strategy when checking results
    ⍝ in a test case; see <http://aplwiki.com/Tester> for details.
      :Access Public Shared
      stop←0 ⋄ stopAt←⊂⍬
      :If 0<⎕NC'x'
          :If 0>x
              stopAt←|x
              stop←1
          :Else
              stop←x
          :EndIf
      :EndIf
      flags←0 1 0,stop,stopAt
      (rc log)←refToTestNamespace Run__ flags
    ∇

    ∇ {log}←testCaseNos RunTheseIn refToTestNamespace;flags;rc
    ⍝ Like RunDebug but it runs just `testCaseNos` in `refToTestNamespace`.\\
    ⍝ Example that executes 'Test_special_02' and 'Test_999':\\
    ⍝ ~~~
    ⍝ 'Special_02' 999 RunTheseIn ⎕THIS
    ⍝ ~~~
    ⍝ 2. Numeric Vector
    ⍝ 3. Vector of length with:
    ⍝    1) A string specifying a group
    ⍝    2) A vector with numbers (empty=all of that group)
    ⍝
    ⍝ Example that executes test cases 2 & 3 of group "Special":
    ⍝ ~~~
    ⍝  'Special' (2 3) RunTheseIn ⎕THIS
    ⍝ ~~~
      :Access Public Shared
      flags←0 1 0 0
      (rc log)←refToTestNamespace Run__ flags,⊂testCaseNos
    ∇

    ∇ EditAll refToTestNamespace;list
     ⍝ :Access Public Shared
     ⍝ Opens all test functions in the editor
      {⎕ED ⍵}&¨GetAllTestFns refToTestNamespace
    ∇

    ∇ r←GetAllTestFns refToTestNamespace;buff
      :Access Public Shared
     ⍝ Returns the names of all test functions found in namespace `refToTestNamespace`
      r←''
      :If ~0∊⍴buff←'T'refToTestNamespace.⎕NL 3
          r←' '~¨⍨↓({∧/(↑¯1↑'_'Split ⍵~' ')∊⎕D}¨↓buff)⌿buff
      :EndIf
    ∇

    ∇ r←{searchString}ListTestCases y;refToTestNamespace;list;b;full
      :Access Public Shared
     ⍝ Returns the comment expected in line 1 of all test cases found in refToTestNamespace.\\
     ⍝ You can specify a string as optional secomd parameter of the right argument:
     ⍝ then only test cases that do contain that string in either their names or in
     ⍝ line 1 will be reported.\\
     ⍝ The optional left argument defaults to 1 which stands for "full", meaning that
     ⍝ the name and the comment in line 1 are returned. If it is 0 insetad,
     ⍝ only the names of the functions are returned.\\
     ⍝ Note that the search will be case insensitive in any case.
      r←''
      (refToTestNamespace full)←2↑y,(⍴,y)↓'' 1
      searchString←##.APLTreeUtils.Lowercase{0<⎕NC ⍵:⍎⍵ ⋄ ''}'searchString'
      :If ~0∊⍴list←'Test_'{⍵⌿⍨⍺∧.=⍨⍵↑[2]⍨⍴⍺}'T'refToTestNamespace.⎕NL 3
      :AndIf ~0∊⍴list←' '~¨⍨↓('Test_'{∧/((⍴⍺)↓[2]⍵)∊' ',⎕D,⎕A,'_',##.APLTreeUtils.Lowercase ⎕A}list)⌿list
          r←2⊃¨refToTestNamespace.⎕NR¨list
          r←{⍵↓⍨+/∧\⍵∊' ⍝'}¨{⍵↓⍨⍵⍳'⍝'}¨r
          :If ~0∊⍴searchString
              b←∨/searchString⍷##.APLTreeUtils.Lowercase⊃r          ⍝ Either in comment...
              b∨←∨/searchString⍷⊃##.APLTreeUtils.Lowercase list     ⍝ ... or in the name.
              r←b⌿r
              list←b⌿list
          :EndIf
          :If full
              r←list,[1.5]r
          :Else
              r←,[1.5]list
          :EndIf
      :EndIf
    ∇

    ∇ {r}←{forceTestTemplate}EstablishHelpersIn refToTestNamespace;∆;list;fnsName;code;buff
    ⍝ Takes a ref to a namespace hosting test cases and establishes some functions,
    ⍝ among them `ListHelpers` which lists all those functions with their leading
    ⍝ comment line.\\
    ⍝ `forceTestTemplate` defaults to 0. If it is a 1 then `Test_0000` is established
    ⍝ no matter whether it -or any other test case- already exists or not.
      :Access Public Shared
      forceTestTemplate←{(0=⎕NC ⍵):0 ⋄ ⍎⍵}'forceTestTemplate'
      'Invalid right argument'⎕SIGNAL 11/⍨~{((,1)≡,⍵)∨((,0)≡,⍵)}forceTestTemplate
      refToTestNamespace←⎕RSI{(0∊⍴⍵):⎕IO⊃⍺ ⋄ ⍵}refToTestNamespace
      'Hosting namespace is scripted'⎕SIGNAL 11/⍨{16::0 ⋄ 1⊣⎕SRC ⍵}refToTestNamespace
      'Invalid right argument'⎕SIGNAL 11/⍨#≡refToTestNamespace
      list←Helpers.GetListHelpers
      :For fnsName :In list
          refToTestNamespace.⎕FX Helpers.GetCode fnsName
      :EndFor
      code←{16::⍬ ⋄ ⎕SRC ⍵}refToTestNamespace
      :If ⍬≢code
          buff←Helpers.GetCode'Test_000'
          (1⊃buff)←'∇  ',1⊃buff
          ((⍴buff)⊃buff)←'∇  ',(⍴buff)⊃buff
          buff←(⊂''),buff,(⊂'')
          code←(¯1↓code),buff,¯1↑code
          refToTestNamespace.⎕FIX code
      :Else
          :If forceTestTemplate
          :OrIf 0∊⍴refToTestNamespace.L''  ⍝ Not if there are already any test functions
              refToTestNamespace.⎕FX Helpers.GetCode'Test_000'
          :EndIf
      :EndIf
    ∇

⍝⍝⍝ Private stuff

    :Field Private Shared ReadOnly ∆OK←0
    :Field Private Shared ReadOnly ∆Failed←1
    :Field Private Shared ReadOnly ∆NoBatchTest←¯1
    :Field Private Shared ReadOnly ∆Inactive←¯2
    :Field Private Shared ReadOnly ∆WindowsOnly←¯10
    :Field Private Shared ReadOnly ∆LinuxOnly←¯11
    :Field Private Shared ReadOnly ∆MacOnly←¯12
    :Field Private Shared ReadOnly ∆LinuxOrMacOnly←¯20
    :Field Private Shared ReadOnly ∆LinuxOrWindowsOnly←¯21
    :Field Private Shared ReadOnly ∆MacOrWindowsOnly←¯22
    :Field Private Shared ReadOnly ∆NoAcreTests←¯30

    ∇ {(rc log)}←ref Run__(trapFlag debugFlag batchFlag stopAt testCaseNos);ps
    ⍝ Run all test cases to be found in "ref"
    ⍝ The right argument:
    ⍝ [1] trapFlag; controls error trapping:
    ⍝     1 = failing test cases are reported, then the next one is executed.
    ⍝     0 = program halts in case of an error - use this for investigation.
    ⍝ [2] "debugFlag". If it is 1 failing tests stop for investigation (stop on error)
    ⍝ [3] batchFlag; a 1 would mean that the test should quit itself iffor example it
    ⍝     needs a human being in front of the monitor. Such test
    ⍝     cases are supposed to do nothing but return a ¯1 when this flag is on.
    ⍝ [4] Integer. Is treated as "stop just before the test case number "stopAt" is _
    ⍝     going to be executed.
    ⍝ The explicit result (shy):
    ⍝ r ←→  0  when all tests got executed succesfully
    ⍝ r ←→  1  when at least one test failed of none where executed because `Initial` prevented that.
    ⍝ r ←→ ¯1  when at least one test wasn't exeuted because it's not appropriate _
    ⍝          for batch execution, although none of the tests executed did fail.
      ps←⎕NS''
      ref.Stop←debugFlag         ⍝ "Stop" is honored by "FailsIf" & "PassesIf"
      ref.⎕EX'INI'               ⍝ Get rid of any leftovers
      ps.(log trapFlag debugFlag batchFlag stopAt testCaseNos errCounter failedCounter)←''trapFlag debugFlag batchFlag stopAt testCaseNos 0 0
      :If ⎕NEXISTS'testcases_',(2 ⎕NQ'#' 'GetEnvironment' 'Computername'),'.ini'
          ref.INI←'flat'(⎕NEW #.IniFiles(,⊂'testcases_',(2 ⎕NQ'#' 'GetEnvironment' 'Computername'),'.ini')).Convert ⎕NS''
      :ElseIf ⎕NEXISTS'Testcases.ini'
          ref.INI←'flat'(⎕NEW #.IniFiles(,⊂'Testcases.ini')).Convert ⎕NS''
      :EndIf
      :If 0=ExecuteInitial ref ps
          log←,⊂'Could not initialize; see ',(⍕↑1↓⎕RSI),'.Initial'
          →∆GetOutOfHere,rc←1
      :EndIf
      :If {16::0 ⋄ 1⊣⎕SRC ⍵}ref
          'Hosting namespace is scripted'⎕SIGNAL 11
      :EndIf
      :If 0∊⍴ps.list←GetAllTestFns ref
          →∆GetOutOfHere,rc←0
      :EndIf
      ProcessGroupAndTestCaseNumbers(ref ps)
      ps.returnCodes←⍬
      →(0∊⍴ps.list)/∆GetOutOfHere
      ps.log,←⊂(⎕PW-1)↑(,'--- Tests started at ',FormatDateTime ⎕TS),' on ',(⍕ref),' ',(⎕PW-1)⍴'-'
      :If ~batchFlag ⋄ ⎕←⊃¯1↑ps.log ⋄ :EndIf
      ps.stopAt∨←¯1∊×ps.testCaseNos
      ProcessTestCases ref ps
     ∆GetOutOfHere:
      ExecuteCleanup ref
      ref.⎕EX'INI'              ⍝ Get rid of any leftovers
      :If 0<ps.⎕NC'list'        ⍝ Then no test cases got executed, probably because `Initial` failed.
          (rc log)←ReportTestResults ps
          ref.TestCasesExecutedAt←FormatDateTime ⎕TS
      :EndIf
    ∇

      GetTestNo←{
      ⍝ Take a string like "Test_001" or "Test_MyGroup_002" and return just the number
          {⍎⌽⍵↑⍨¯1+⍨⍵⍳'_'}⌽⍵
      }

    ∇ {r}←ExecuteInitial(ref parms)
      r←1
      :If 3=ref.⎕NC'Initial'
          :Select ↑(⎕IO+1)⊃1 ref.⎕AT'Initial'
          :Case 0
              :If 0=↑↑ref.⎕AT'Initial'
                  ref.Initial
              :Else
                  r←ref.Initial
              :EndIf
          :Case 1
              :If 0=↑↑ref.⎕AT'Initial'
                  ref.Initial parms
              :Else
                  r←ref.Initial parms
              :EndIf
          :Else
              11 ⎕SIGNAL⍨'The "Initial" function in ',(⍕ref),' has an invalid signature: it''s neither monadic nor niladic'
          :EndSelect
      :EndIf
    ∇

    ∇ ProcessGroupAndTestCaseNumbers(ref ps);rc;lookFor;buff
      ps.group←''
      :If ~0∊⍴ps.testCaseNos
          :If ' '=1↑0⍴∊ps.testCaseNos
              :If 0 1∊⍨≡ps.testCaseNos
                  ps.group←ps.testCaseNos
                  ps.testCaseNos←⍬
              :Else
                  ps.group←1⊃ps.testCaseNos
                  ps.testCaseNos←∊1↓ps.testCaseNos
              :EndIf
          :Else
              ps.group←''
          :EndIf
          :If ~0∊⍴ps.group
              :If 3=ref.⎕NC ps.group
                  ps.list←,⊂ps.group
                  ps.group←''
              :Else
                  lookFor←(('Test_'{⍵≡(⍴⍺)↑⍵}ps.group)/'_'),ps.group
                  :If '*'=¯1↑lookFor
                      lookFor←¯1↓lookFor
                      ps.list←(∨/¨(⊂lookFor)⍷¨ps.list)/ps.list  ⍝ First restrict to group
                  :Else
                      :If 0∊⍴buff←(∨/¨(⊂lookFor)⍷¨ps.list)/ps.list  ⍝ First restrict to group
                          ps.list←''
                      :Else
                          ps.list←(1=⍴∪{2⊃'_'Split ⍵}¨buff)/buff
                      :EndIf
                  :EndIf
              :EndIf
          :EndIf
          :If 0∊⍴ps.list ⋄ →rc←0 ⋄ :EndIf
          :If (,0)≡,ps.testCaseNos
              ps.testCaseNos←¯1
          :Else
              :If ~0∊⍴ps.testCaseNos
                  :If 0∊⍴ps.group
                      :If 0∊⍴ps.list←(1={'_'+.=⍵}¨ps.list)/ps.list
                          →rc←0
                      :EndIf
                  :EndIf
              :AndIf 0∊⍴ps.list←((GetTestNo¨ps.list)∊|ps.testCaseNos)/ps.list   ⍝ Now select the numbers
                  →rc←0
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ ProcessTestCases(ref ps);width;i;noOf;this;testNo;rc;msg
      width←⌈/⍴¨ps.list
      :For i :In ⍳noOf←⍴ps.list
          this←i⊃ps.list
          testNo←GetTestNo this
          :Trap ps.trapFlag/0
              rc←ExecuteTestFunction ref ps testNo this
              ps.failedCounter+←rc=1
              :If 0>rc
                  ps.returnCodes,←rc
              :EndIf
              msg←{⍵↓⍨+/∧\' '=⍵}{⍵↓⍨⍵⍳'⍝'}2⊃ref.⎕NR this
              ps.log,←⊂('* '[1+rc∊0 ¯1]),' ',this,' (',(⍕i),' of ',(⍕noOf),') : ',msg
              :If 0>rc
                  :If 0<ps.errCounter
                      rc←1
                      :Continue
                  :EndIf
              :Else
                  ⎕←⊃¯1↑ps.log
              :EndIf
          :Else
              ps.errCounter+←1
              msg←{⍵↓⍨+/∧\' '=⍵}{⍵↓⍨⍵⍳'⍝'}2⊃ref.⎕NR this
              ps.log,←⊂'# ',this,,' (',(⍕i),' of ',(⍕noOf),') : ',msg
              :If ~ps.batchFlag
                  ⎕←⊃¯1↑ps.log
              :EndIf
          :EndTrap
      :EndFor
⍝Done
    ∇

    ∇ HandleStops(fns ps StopHere testNo)
      :If 0<ps.stopAt
      :AndIf testNo≥ps.stopAt
          (∪(⎕STOP fns),StopHere)⎕STOP fns
      :Else
          ((⎕STOP fns)~StopHere)⎕STOP fns
      :EndIf
    ∇

    ∇ (rc log)←ReportTestResults ps
      log←ps.log
      log,←⊂(⎕PW-2)⍴'-'
      log,←⊂'  ',(⍕1⊃⍴ps.list),' test case',((1≠1⊃⍴ps.list)/'s'),' executed'
      log,←⊂'  ',(⍕ps.failedCounter),' test case',((1≠+/ps.failedCounter)/'s'),' failed'
      log,←⊂'  ',(⍕ps.errCounter),' test case',((1≠+/ps.errCounter)/'s'),' broken'
      :If ~0∊⍴ps.returnCodes
          :If ∆NoBatchTest∊ps.returnCodes
              log,←⊂'  ',(⍕¯1+.=ps.returnCodes),' test cases not executed because they are not "batchable"'
          :EndIf
          :If ∆Inactive∊ps.returnCodes
              log,←⊂'  ',(⍕¯2+.=ps.returnCodes),' test cases not executed because they were inactive'
          :EndIf
          :If ∆WindowsOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆WindowsOnly+.=ps.returnCodes),' test cases not executed because they can only run under Window'
          :EndIf
          :If ∆LinuxOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆LinuxOnly+.=ps.returnCodes),' test cases not executed because they can only run under Linux'
          :EndIf
          :If ∆MacOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆MacOnly+.=ps.returnCodes),' test cases not executed because they can only run under Mac OS'
          :EndIf
          :If ∆LinuxOrMacOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆LinuxOrMacOnly+.=ps.returnCodes),' test cases not executed because they can only run under Linux or Mac OS'
          :EndIf
          :If ∆LinuxOrWindowsOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆LinuxOrWindowsOnly+.=ps.returnCodes),' test cases not executed because they can only run under Linux or Windows'
          :EndIf
          :If ∆MacOrWindowsOnly∊ps.returnCodes
              log,←⊂'  ',(⍕∆MacOrWindowsOnly+.=ps.returnCodes),' test cases not executed because they can only run under Mac OS or Windows'
          :EndIf
          :If ∆NoAcreTests∊ps.returnCodes
              log,←⊂'  ',(⍕∆NoAcreTests+.=ps.returnCodes),' test cases not executed because they are acre-related'
          :EndIf
      :EndIf
      :If ~ps.batchFlag
          ⎕←,[1.5](-4+~0∊⍴ps.returnCodes)↑log
      :EndIf
      :If 0<ps.failedCounter+ps.errCounter
          rc←1
      :Else
          rc←2×~0∊⍴ps.returnCodes
      :EndIf
    ∇

    ∇ ExecuteCleanup ref
      :If 3=ref.⎕NC'Cleanup'
          ref.Cleanup
      :EndIf
    ∇

    ∇ rc←ExecuteTestFunction(ref ps testNo fnsName)
      :If 0=ps.batchFlag
      :AndIf 0=+/';⎕TRAP;'⍷Uppercase{';',⍵,';'}{⍵↓⍨⍵⍳';'}{⍵↑⍨¯1+⍵⍳'⍝'}↑ref.⎕NR fnsName
          ⎕←'  *** WARNING: ⎕TRAP is not localized in ',(⍕ref),'.',fnsName
      :EndIf
      HandleStops(1⊃⎕SI)ps ∆StopHere testNo
     ∆StopHere:rc←ref.⍎fnsName,' ',(⍕ps.debugFlag),' ',(⍕ps.batchFlag)
    ∇


    :Class Helpers
⍝ All private (!) functions of this sub class are going to be established within the
⍝ target namespace in case the `EstablishHelpersIn` method is called.

          FailsIf←{
⍝ Usage : →FailsIf x, where x is a boolean scalar
              ⎕TRAP←(999 'E' '(⎕IO⊃⎕DM)⎕SIGNAL 999')(0 'N')
              PassesIf~⍵                   ⍝ Just PassesIf on negation
          }

          PassesIf←{
⍝ Usage : →PassesIf x, where x is a boolean scalar
              ⍵:⍬                     ⍝ Passes test, so →PassesIf x just continues
              0=⎕NC'stopFlag':0       ⍝ Stop not defined, continue with test suite
              ~stopFlag:0             ⍝ Do not stop, continue with test suite
              ⎕SIGNAL 999             ⍝ Otherwise stop for investigation
          }

        ∇ r←{label}GoToTidyUp flag
⍝ Returns either an empty vector or "Label" which defaults to ∆TidyUp
⍝ but signals 999 when flag=1 and "stopFlag" exists and is 1.
          :If 1=flag
          :AndIf 0<⎕NC'stopFlag'
          :AndIf stopFlag
              ⎕SIGNAL 999
          :EndIf
          label←{(0<⎕NC ⍵):⍎⍵ ⋄ r←⍎'∆TidyUp'}'label'
          r←flag/label
        ∇

        ∇ {r}←Run
⍝ Run all test cases
          r←#.Tester.Run ⎕THIS
        ∇

        ∇ {r}←RunDebug debugFlag
⍝ Run all test cases with DEBUG flag on
⍝ If `debugFlag` is 1 then `RunDebug` stops just before executing any specific test case.
          r←debugFlag #.Tester.RunDebug ⎕THIS
        ∇

        ∇ {r}←RunBatchTestsInDebugMode
⍝ Run all batch tests in debug mode (no error trapping) and with stopFlag←1.
          r←0 1 #.Tester.RunBatchTests ⎕THIS
        ∇

        ∇ {r}←RunBatchTests
⍝ Run all batch tests
          r←#.Tester.RunBatchTests ⎕THIS
        ∇

        ∇ {r}←RunThese ids
⍝ Run just the specified tests.
⍝
⍝ `ids` can be one of:
⍝ * A scalar or vector of numbers identifying ungrouped testcases.
⍝ * A text string that uniquily identified a group.
⍝ * A text string that ends with a start (*) identifying one or more test groups.
⍝ * A two-item vector with:
⍝   * A text string identifying a group
⍝   * An integer vector identifying test cases within that group.
⍝
⍝ If negative numbers are used then they would still idendifying the test cases but
⍝ `Tester` would feature a stop vctor just before any test case it actually executed,
⍝ allowing the user to investigate.
          r←ids #.Tester.RunTheseIn ⎕THIS
        ∇

        ∇ {list}←E list
⍝ Get all functions into the editor starting their names with "Test_".
          :If 0∊⍴list
              list←'T'⎕NL 3
          :ElseIf 2=⍴⍴list
              list←{⎕ML←3 ⋄ ⊃⍵}list[;⎕IO]
          :Else
              'Invalid right argument'⎕SIGNAL 11
          :EndIf
          {(0∊⍴⍵): ⋄ ⎕ML←3 ⋄ ⎕ED⊃⍵}&↓'Test_'{⍵⌿⍨⍺∧.=⍨(⍴,⍺)↑[1+⎕IO]⍵}list
        ∇

        ∇ r←{numbers}L group
⍝ Prints a list with all test cases and the first comment line to the session.
⍝ If "group" is not empty then it will print only that group (case independent).
⍝ May or may not start with "Test_"
⍝ If "numbers" is defined only those number are printed.
          numbers←{(0<⎕NC ⍵):⍎⍵ ⋄ ⍬}'numbers'
          r←↓'Test_'{⍵⌿⍨((⍴⍺)↑[1+⎕IO]⍵)∧.=⍺}'T'⎕NL 3
          :If ~0∊⍴group
              group←#.APLTreeUtils.Lowercase'test_'{((⍺≢(⍴⍺)↑⍵)/⍺),⍵}group
              r←(({⎕ML←1 ⋄ ↑⍵}#.APLTreeUtils.Lowercase(⍴group)↑¨r)∧.=group)⌿r
          :EndIf
          :If ~0∊⍴r
          :AndIf ~0∊⍴numbers
              r←(({⍎⍵↑⍨-(-⎕IO)+'_'⍳⍨⌽⍵}¨r)∊numbers)⌿r
          :EndIf
          r←r,⍪{⎕ML←3 ⋄ {⍵↓⍨+/∧\' '=⍵}{⎕IO←1 ⋄ ⍵↓⍨⍵⍳'⍝'}∊1↑1↓⎕NR ⍵}¨r
        ∇

        ∇ r←G;⎕IO
⍝ Prints all groups to the session.
          ⎕IO←0
          r←↓'Test_'{⍵⌿⍨((⍴⍺)↑[1]⍵)∧.=⍺}'T'⎕NL 3
          :If ~0∊⍴r←(2='_'+.=⍉{⎕ML←1 ⋄ ↑⍵}r)⌿r
          :AndIf ~0∊⍴r←{⎕ML←1 ⋄ ↑⍵}∪{⍵↑⍨⍵⍳'_'}¨{⍵↓⍨1+⍵⍳'_'}¨r
              r←r[⍋#.APLTreeUtils.Lowercase r;]
          :EndIf
        ∇

        ∇ {r}←oldName RenameTestFnsTo newName;⎕IO;body;rc;⎕ML;header;comment;res;name;right;left;newParent;oldParent;delFilanme
⍝ Renames a test function and tell acre.
⍝ r ← ⍬
          ⎕IO←0 ⋄ ⎕ML←3
          r←⍬
          (oldName newName)←oldName newName~¨' '
          :If '.'∊oldName
              (oldParent oldName)←¯1 0↓¨'.'#.APLTreeUtils.SplitPath oldName
              oldParent←⍎oldParent
          :Else
              oldParent←↑⎕RSI
          :EndIf
          :If '.'∊newName
              (newParent newName)←¯1 0↓¨'.'#.APLTreeUtils.SplitPath newName
              newParent←⍎newParent
          :Else
              newParent←↑⎕RSI
          :EndIf
          ⎕SIGNAL 11/⍨oldParent≢newParent
          'Function to be renamed not found'⎕SIGNAL 11/⍨3≠oldParent.⎕NC oldName
          'New name is already used'⎕SIGNAL 11/⍨0<newParent.⎕NC newName
          'New name is invalid'⎕SIGNAL 11/⍨¯1=newParent.⎕NC newName
          body←oldParent.⎕NR oldName
          header←0⊃body
          (header comment)←header{(⍵↑⍺)(⍵↓⍺)}header⍳'⍝'
          :If (oldParent.⎕NC⊂oldName)∊3.2   ⍝ Dfns
              :If 1=⍴body
                  (oldName body)←{⍵{(⍵↑⍺)(⍵↓⍺)}⍵⍳'←'}0⊃body
                  body←,⊂newName,body
                  oldName~←' '
              :Else
                  (0⊃body)←newName,'←{'
              :EndIf
          :Else
              (res header)←header{~'←'∊⍺:''⍺ ⋄ ((1+⍵)↑⍺)((1+⍵)↓⍺)}header⍳'←'
              :If '('∊header
                  (header right)←header{(⍵↑⍺)(⍵↓⍺)}header⍳'('
                  header←{⍵⊂⍨' '≠⍵}header
                  :Select ⍬⍴⍴header
                  :Case 1       ⍝ Monadic fns
                      name←header
                      left←''
                  :Case 2        ⍝ Dyadic fns
                      (left name)←header
                  :Else
                      .          ⍝ ?!
                  :EndSelect
              :Else
                  header←{⍵⊂⍨' '≠⍵}header
                  :Select ⍬⍴⍴header
                  :Case 1        ⍝ Niladic fns
                      name←header
                      left←right←''
                  :Case 2        ⍝ Monadic fns
                      (name right)←header
                      left←''
                  :Case 3        ⍝ Dyadic fns
                      (name right left)←header
                  :Else
                      .          ⍝ ?!
                  :EndSelect
              :EndIf
              name←newName
              (0⊃body)←res,left,' ',name,' ',right,comment
          :EndIf
          :If ' '≠1↑0⍴rc←newParent.⎕FX⊃body
              . ⍝ something went wrong
          :EndIf
          :If 0=#.⎕NC'acre'
              ⎕←'acre not found in the workspace'
              oldParent.⎕EX oldName
          :Else
              (oldName newName)←{(⍕newParent),'.',⍵}¨oldName newName
              delFilanme←(↑#.acre.GetChangeFileName newName),'.DEL'
              :If ⎕NEXISTS delFilanme
                  ⎕NDELETE delFilanme
              :EndIf
              :If 0∊⍴rc←#.acre.SetChanged newName
                  ⎕←'acre was told about the introduction of a new test fns but it was not interested.'
              :EndIf
              :If 0∊⍴rc←#.acre.Erase oldName
                  ⎕←'acre was told about the deletion of a test fns but it was not interested.'
              :EndIf
              ⎕EX oldName
              ⎕←'***Done'
          :EndIf
        ∇

        ∇ r←ListHelpers;list;Mix
⍝ Lists all helpers available from the `Tester` class.
⍝ These are all established by calling the `EstablishHelpers' method.
          r←0 2⍴' '
          list←'Run' 'RunDebug' 'RunThese' 'RunBatchTests' 'RunBatchTestsInDebugMode' 'E' 'L' 'G' 'FailsIf' 'PassesIf'
          list,←'GoToTidyUp' 'RenameTestFnsTo' 'ListHelpers' '∆OK' '∆Failed' '∆NoBatchTest' '∆Inactive' '∆NoAcreTests'
          list,←'∆WindowsOnly' '∆LinuxOnly' '∆MacOnly' '∆LinuxOrMacOnly' '∆LinuxOrWindowsOnly' '∆MacOrWindowsOnly'
          list←,¨list
          Mix←{⎕ML←3 ⋄ ⊃⍵}
          r←Mix{⍵(#.APLTreeUtils.dlb{⍺⍺{⍵↓⍨(~⎕IO)+⍵⍳'⍝'}⍺⍺ ⍵}⎕IO⊃1↓⎕NR ⍵)}¨list
        ∇

        ∇ r←GetCode name
          :Access Public Shared
⍝ Useful to get the code of any private function of the `Helpers` sub class.
          r←⎕NR name
        ∇

        ∇ r←GetListHelpers
          :Access Public Shared
⍝ Returns a list of all helper functions
⍝ These are defined as all private functions of the sub class `Helpers`.

⍝ ↓↓↓↓ Circumvention of Dyalog bug <01154> (⎕nl 3 does NOT list the rpivate functions of `Helpers`!)
          r←ListHelpers[;1]
        ∇

        ∇ R←Test_000(stopFlag type);⎕TRAP
⍝ Model for a test function.
          ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
          R←∆Failed

⍝ Preconditions...
⍝ ...

          →PassesIf 1≡1
          →FailsIf 1≢1
          →GoToTidyUp 1≢1
          R←∆OK

         ∆TidyUp: ⍝ Clean up after this label
          ⍝ ...

        ∇

        ∇ r←∆OK
        ⍝ Constant; used as result of a test function
          r←0
        ∇

        ∇ r←∆Failed
        ⍝ Constant; used as result of a test function
          r←1
        ∇

        ∇ r←∆NoBatchTest
        ⍝ Constant; used as result of a test function
          r←¯1
        ∇

        ∇ r←∆Inactive
        ⍝ Constant; used as result of a test function
          r←¯2
        ∇

        ∇ r←∆WindowsOnly
        ⍝ Constant; used as result of a test function
          r←¯10
        ∇

        ∇ r←∆LinuxOnly
        ⍝ Constant; used as result of a test function
          r←¯11
        ∇

        ∇ r←∆MacOnly
        ⍝ Constant; used as result of a test function
          r←¯12
        ∇

        ∇ r←∆LinuxOrMacOnly
        ⍝ Constant; used as result of a test function
          r←¯20
        ∇

        ∇ r←∆LinuxOrWindowsOnly
        ⍝ Constant; used as result of a test function
          r←¯21
        ∇

        ∇ r←∆MacOrWindowsOnly
        ⍝ Constant; used as result of a test function
          r←¯22
        ∇

        ∇ r←∆NoAcreTests
        ⍝ Constant; used as result of a test function
          r←¯30
        ∇

    :EndClass

:EndClass
