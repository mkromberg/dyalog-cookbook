{:: encoding="utf-8" /}

# Logging what happens 

MyApp 1.0 is now working, but handles errors poorly. See what happens when we try to work on a non-existent file/folder:

~~~
Z:\code\v02\MyApp.exe Z:\texts\Does_not_exist
~~~

We see an alert message: _This Dyalog APL runtime application has attempted to use the APL session and will therefore be closed._ 

`MyApp` failed, because there is no file or folder `Z:\texts\Does_not_exist`. That triggered an error in the APL code. The interpreter tried to signal the error to the session. But a runtime task has no session, so at that point the interpreter popped the alert message and `MyApp` died.   

T> As soon as you close the message box a CONTINUE workspace will be created as a sibling of the EXE. Such a CONTINUE WS can be loaded and investigated, making it easy to figure out what the problem is. However, this is only true as long as there is only a single thread running in the EXE. 
T> 
T> Note that for analyzing purposes a CONTINUE workspace must be loaded in an already running instance of Dyalog. In other words: don't double-click a CONTINUE! The reason is that `⎕DM` and `⎕DMX` are overwritten in the process of booting SALT, meaning that you loose the error message. That might be a problem or not: if you can simply re-execute the failing line it will produce the same error again but if it is, say, reading from a previously tied file then that cannot work because that file is of course not tied anymore when you load the CONTINUE.

The next version of `MyApp` could do better by having the program write a log file recording what happens.

Save a copy of `Z:\code\v03` as `Z:\code\v04`.

We'll use the APLTree `Logger` class, which we'll now install in the workspace root. If you've not already done so, copy the APLTree library folder into `Z:\code`.[^apltree] Now edit `Z:\code\v04\MyApp.dyapp` to include some library code:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\OS
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run #.MyApp.SetLX ⍬
~~~ 

and run the DYAPP to recreate the `MyApp` workspace. 

A> ### Getting help with any APLTree members
A> 
A> Note that you can ask for a detailed documentation for how to use the members of the APLTree project by executing:
A> 
A> ~~~
A> ]ADOC_Browse APLTreeUtils
A> ~~~
A> 
A> I> If the user command `]ADOC_browse` is not available you should issue the `]uupdate` command. That would bring all Dyalog user commands up to date. `ADOC_Browse`, `ADOC_List` and `ADOC_Help` should then all be available.

The `Logger` class is now part of `MyApp` together with some dependencies: 

* `APLTreeUtils` is a namespace that contains some functions needed by most applications. All members of the APLTree library depend on it.
* `FilesAndDirs` is a class that offers method for handling files and directories.
* `OS` contains a couple of OS-independent methods for common tasks. `KillProcess` is just an example. `FilesAndDirs` needs `OS` under some circumstances.

Let's get the program to log what it's doing. Within `MyApp`, some changes. Some aliases for the new code:

~~~
⍝ === Aliases (referents must be defined previously)

    F←##.FilesAndDirs ⋄ A←##.APLTreeUtils   ⍝ from the APLTree lib
~~~

Note that `APLTreeUtils` comes with the functions `Uppercase` and `Lowercase`. We have those already in the `Utilities` namespace. This violates the DRY principle. We should get rid of one version and use the other everywhere. But how to choose?

First of all, almost all APLTree projects rely on `APLTreeUtils`. If you want to use this library then we cannot get rid of `APLTreeUtils`. 

The two different versions both use the Dyalog `⌶` function, so comparing functionality and speed won't help.

However, `APLTreeUtils` is in use for more than 10 years now, it comes with a comprehensive set of test cases and it is documented in detail. That makes the choice rather easy.

Therefore we remove the two functions from `Utilities` and change `CountLetters←`:

~~~
      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Accents U.map A.Uppercase ⍵
      }
~~~

That works because the alias `A` we've just introduced points to `APLTreeUtils`.


## Where to keep the logfiles? 

Where is `MyApp` to write the logfile? We need a filepath we know exists. That rules out `fullfilepath`. We need a logfile even if that isn't a valid path.  

We'll write logfiles into a subfolder of the current directory. Where will that be? When the EXE launches, the current directory is set:

~~~
Z:\code\v04\MyApp.exe Z:\texts\en
~~~

Current directory is `Z:\` and therefore that's where the logfiles will appear.

If this version of `MyApp` were for shipping that would be a problem. An application installed in `C:\Program Files` cannot rely on being able to write logfiles there. That is a problem to be solved by an installer. We'll come to that later. But for this version of `MyApp` the logfiles are for your eyes only. It's fine that the logfiles appear wherever you launch the EXE. You just have to know where they are. We will put them into a sub folder `Logs` within the current directory.

In developing and testing `MyApp`, we create the active workspace by running `MyApp.dyapp`. The interpreter sets the current directory of the active workspace as the DYAPP's parent folder for us. That too is sure to exist. 

~~~
      #.FilesAndDirs.PWD
Z:\code\v04
~~~

Now we set up the parameters needed to instantiate the Logger class. First we use the Logger class' shared `CreateParms` method to get a parameter space with an initial set of default parameters. You can use the built-in method `∆List` to display its properties and their defaults:

~~~
      #.Logger.CreateParms.∆List''
  active                   1    
  autoReOpen               1    
  debug                    0    
  encoding              ANSI    
  errorPrefix      *** ERROR    
  extension              log    
  fileFlag                 1    
  filename                      
  filenamePostfix               
  filenamePrefix                
  filenameType          DATE    
  path                          
  printToSession           0    
  timestamp                     
~~~

We then modify those where the defaults don't match our needs and use the parameter space to create the Logger object. For this we create a function `OpenLogFile`:

~~~
    ∇ instance←OpenLogFile path;logParms
      ⍝ Creates an instance of the "Logger" class.
      ⍝ Provides methods `Log` and `LogError`.
      ⍝ Make sure that `path` (that is where log files will end up) does exist.
      ⍝ Returns the instance.
      logParms←##.Logger.CreateParms
      logParms.path←path
      logParms.encoding←'UTF8'
      logParms.filenamePrefix←'MyApp'
      'CREATE!'F.CheckPath path
      instance←⎕NEW ##.Logger(,⊂logParms)
    ∇
~~~

Notes:

* We need to make sure that the current directory contains a `Logs` folder. That's what the method `FilesAndDirs.CheckPath` will ensure when the left argument is the string `'Create!'`.

* We change the default encoding -- that's "ANSI" -- to "UTF-8". Note that this has pros and cons: it allows us to write APL characters to
  the log file but it will also cause potential problems with any third-party tools dealing with log files, because many of them 
  insist on any log file to carry just ANSI characters.

  Although we've changed it here for demonstration purposes we recommend sticking with ANSI unless you have a _very_ good reason 
  not to. When we introduce proper error handling in chapter 6 there won't be a need for having APL characters in the log file anyway.
  
* Since we have not changed either `autoReOpen` (1) or `filenameType` ("DATE") it tells the `Logger` class that it should automatically 
  close a log file and re-open a new one each day at 24:00. It also defines (together with `filenamePrefix`) the name of the log file.

* If we would run `OpenLogFile` and allow it to return its result to the session window then something similar to this would appear:

   ~~~
   [Logger:Logs\MyApp_20170211.log(¯87200436)]
   ~~~
   
   * "Logger" just tells us the name of the class the object was instantiated from.
   
   * The path between `:` and `(` tell us the actual filename of the log file. Because the `filenameType` is "DATE" the name carries 
     the year, month and day the log file was opened. 
     
   * The negative number is the tie number of the log file.  


We create a function `Initial` (short for "Initialize") which calls `OpenLogFile` and returns the `Logger` instance:

~~~
    ∇ {MyLogger}←Initial dummy
    ⍝ Prepares the application.
    ⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      MyLogger←OpenLogFile'Logs'
    ∇
~~~

At the moment `Initial` is not doing too much, but that will change. Note that we took the opportunity to make sure that all the system settings in `#` are set according to our needs.

Next we need to change `TxtToCsv`, and while we are at it we are going to improve it: we move the code that processes `fullfilepath` into a function `GetFiles`:

~~~
    ∇ (target files)←GetFiles fullfilepath;csv;target;path;stem
      fullfilepath~←'"'
      csv←'.csv'
      :Select C.NINFO.TYPE ⎕NINFO fullfilepath
      :Case C.TYPES.DIRECTORY
          target←F.NormalizePath fullfilepath,'\total',csv
          files←⊃F.Dir fullfilepath,'\*.txt'
      :Case C.TYPES.FILE
          (path stem)←2↑⎕NPARTS fullfilepath
          target←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect
       target←(~0∊⍴files)/target
    ∇
~~~

That allows us to keep `TxtToCsv` nice and tidy and the list of local variables short.

We make one change in `ProcessFile`:

~~~
    ∇ data←(fns ProcessFiles)files;txt;file
   ⍝ Reads all files and executes `fns` on the contents.
      data←⍬
      :For file :In files
          txt←'flat' A.ReadUtf8File file
          data,←⊂fns txt
      :EndFor
    ∇
~~~

We use `APLTreeUtils.ReadUtf8File` rather than `⎕NGET` for several reasons:

  1. It simplifies matters because the function deals with end-of-line characters automatically, no matter what the current operating system is. 
  1. The function takes care of a BOM [^bom] by removing it.
  
`ReadUtf8File` returns a vtv by default: one item per record. We need a simple text vector. Although it is easy enough to flatten `ReadUtf8File`'s result (`⊃,/`) it is more efficient to tell `ReadUtf8File` not to split the stream into records in the first place.

Now we have to make sure that `Initial` is called from `StartFromCmdLine`:

~~~
    ∇ {r}←StartFromCmdLine arg;MyLogger
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      MyLogger←Initial ⍬
      r←TxtToCsv arg
    ∇
~~~

We also have to make sure that `GetFiles` is called from `TxtToCsv`. In addition we add logging functionality:

~~~
∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
⍝ Write a sibling CSV of the TXT located at fullfilepath,
⍝ containing a frequency count of the letters in the file text      
   MyLogger.Log'Started MyApp in ',F.PWD
   MyLogger.Log'Source: ',fullfilepath
   (target files)←GetFiles fullfilepath
   :If 0∊⍴files
       MyLogger.Log'No files found to process'
       rc←1
   :Else
       tbl←⊃⍪/(CountLetters ProcessFiles)files
       lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
       A.WriteUtf8File target lines 
       MyLogger.Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
       MyLogger.Log' ',↑files
       rc←0
   :EndIf
∇
~~~

Notes:

* We are now using `FilesAndDirs.Dir` rather than the Dyalog primitive `⎕NINFO`. Apart from offering recursive searches (a feature we don't need here) the `Dir` function also normalizes the separator character. Under Windows it will always be a backslash while under Linux it is always a slash character.

* We use `APLTreeUtils.WriteUtf8File` rather than `⎕NPUT` for several reasons:

  1. It simplifies matters because these functions deal with end-of-line characters automatically, no matter what the current operating system is.
  1. It will either overwrite an existing file or create a new one for us. It will also try several times in case something goes wrong. This is often helpful when a slippery network is involved.
  
* We could have written `A.WriteUtf8File target ({⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl)`, avoiding the local variable `lines`. We didn't because this variable might be very helpful in case something goes wrong and we need to trace through the `TxtToCsv` function.

* Note that we do not pass `MyLogger` as an argument to `TxtToCsv`. We could, and some would say we should. We will discuss this issue in detail in the "Configuration settings" chapter.

Finally we change `Version`:

~~~
∇r←Version
  ⍝ * 1.0.0
  ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
  ⍝ * 1.1.0:
  ⍝   * Can now deal with non-existent files.
  ⍝   * Logging implemented.
    r←(⍕⎕THIS) '1.1.0' '2017-02-26'             
∇
~~~    

The foreseeable error that aborted the runtime task -- on an invalid filepath -- has now been replaced by a message saying no files were found. We have also changed the explicit result. So far it has returned the number of bytes written. In case something goes wrong ("file not found" etc.) it will return `¯1` now.

As the logging starts and ends in `TxtToCsv`, we can run this in the workspace now to test it. (Later we will see that this approach has its disadvantages, and that there are better ways of doing this)

~~~
      #.MyApp.TxtToCsv 'Z:\texts\en'
      ⊃(⎕NINFO⍠1) 'Logs\*.LOG'
 MyApp_20160406.log 
      ↑⎕NGET 'Logs\MyApp_20160406.log'
2016-04-06 13:42:43 *** Log File opened
2016-04-06 13:42:43 (0) Started MyApp in Z:\
2016-04-06 13:42:43 (0) Source: Z:\texts\en
2016-04-06 13:42:43 (0) Target: Z:\texts\en.csv
2016-04-06 13:42:43 (0) 244 bytes written to Z:\texts\en.csv
2016-04-06 13:42:43 (0) All done
~~~

I> Alternatively you could set the parameter `printToSession` -- which defaults to 0 -- to 1. That would let the Logger class write all the messages not only to the log file but also to the session. That can be quite useful for test cases or during development. You could even prevent the Logger class to write to the disk at all by setting `fileFlag` to 0.

I> The Logger class is designed to never break your application -- for obvious reasons. The drawback of this is that if something goes wrong like the path becoming invalid because the drive got removed you would only notice by trying to look at the log files. You can however tell the Logger class that it should **not** trap all errors by setting the parameter `debug` to 1. Then Logger would crash if something goes wrong.

Let's see if logging works also for the exported EXE. Run the DYAPP to rebuild the workspace. Export as before and then run the new `MyApp.exe` in a Windows console.

~~~
Z:\code\v04\MyApp.exe Z:\texts\en
~~~

Yes! The output TXT gets produced as before, and the work gets logged in `Z:\Logs`. 

Let's see what happens now when the filepath is invalid. 

~~~
Z:\code\v04\MyApp.exe Z:\texts\de
~~~

No warning message -- the program made an orderly finish. And the log?

~~~
      ↑⎕NGET 'Logs\MyApp_20160406.log'
2017-02-26 10:54:01 *** Log File opened
2017-02-26 10:54:01 (0) Started MyApp in Z:\code\v04
2017-02-26 10:54:01 (0) Source: G:\Does_not_exist
2017-02-26 10:54:01 (0) No files found to process
2017-02-26 10:54:26 *** Log File opened
2017-02-26 10:54:26 (0) Started MyApp in Z:\code\v04
2017-02-26 10:54:26 (0) Source: "Z:\texts\en\ageofinnocence.txt"
2017-02-26 10:54:26 (0) 1 file processed.
2017-02-26 10:58:07 (0) Z:/texts/en/ageofinnocence.txt 
2017-02-26 10:54:35 *** Log File opened
2017-02-26 10:54:35 (0) Started MyApp in Z:\code\v04
2017-02-26 10:54:35 (0) Source: "Z:\texts\en\"
2017-02-26 10:54:35 (0) 9 files processed.
2017-02-26 10:58:07 (0) Z:/texts/en/ageofinnocence.txt 
... 
~~~

I> In case you wonder what the `(0)` in the log file stands for: this reports the thread number that has written to the log file. Since we do not use threads this is always `(0)` = the main thread the interpreter is running in.

One more improvement in `MyApp`: we change the setting of the system variables from

~~~
(⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←1 1 3 15 1
~~~

to

~~~
⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3 ⋄ ⎕PP←15 ⋄ ⎕DIV←1
~~~

This is more readable and therefore better.

We now have `MyApp` logging its work in a subfolder of the application folder and reporting problems which it has anticipated.

Next we need to consider how to handle and report errors we have _not_ anticipated. We should also return some kind of error code to Windows. If `MyApp` encounters an error, any process calling it needs to know. 

A> ### Destructors and the Tracer
A>
A> When you trace through `TxtToCsv` the moment you leave the function the Tracer shows the function `Cleanup` of the `Logger` class. The function is declared as a destructor.
A>
A> In case you wonder why that is: a destructor (if any) is called when the instance of a class is destroyed. Not necessarily immediately but eventually. Now we have created an instance of the `Logger` class which we have called `MyLogger`. This name is localyzed in the header of `TxtToCsv`, meaning that when `TxtToCsv` finishes the instance is implicitly deleted. That makes the interpreter executing the destructor, and because the Tracer was up and running this destructor makes an appearance in the Tracer.

[^apltree]: You can download the complete APLTree library from the [APL Wiki](http://download.aplwiki.com/).
[^bom]: https://en.wikipedia.org/wiki/Byte_order_mark