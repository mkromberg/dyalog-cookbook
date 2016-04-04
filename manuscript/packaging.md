# Package MyApp as an executable


## Output to the session log

Now let's package `MyApp` as an EXE. It's going to run without a user interface (UI). It won't have a session. What happens to values that would otherwise appear in the session log? They disappear. That’s not actually a problem, but it’s tidy to catch anything that would otherwise be written to the UI, including empty arrays. 

`TxtToCsv` has a shy result. That’s fine as it is. 

We'll also fix three key environment variables for it in `MyApp`:

~~~
(⎕IO ⎕ML ⎕WX)←1 1 3 ⍝ environment variables
~~~


## Reading arguments from the command line 

`TxtToCsv` needs an argument. The EXE must take it from the command line. We'll give `MyApp` a niladic function `StartFromCmdLine`. The DYAPP will use it to start the program:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~

and in `MyApp.dyalog`:

~~~
     ∇ SetLX
[1]   ⍝ Set Latent Expression in root ready to export workspace as EXE
[2]    #.⎕LX←'MyApp.StartFromCmdLine'
     ∇

     ∇ StartFromCmdLine;args
[1]   ⍝ Read command parameters, run the application
[2]      {}TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'getcommandlineargs'
     ∇
~~~

This is how MyApp will run when called from the Windows command line. 

We're now nearly ready to export the first version of our EXE. 

1. From the File menu pick *Export*. 
2. Pick (say) `e:\dev\MyApp` as the destination folder. 
3. From the list *Save as type* pick *Standalone Executable*. 
4. Set the *File name* as `MyApp`.
5. Check the *Runtime application* and *Console application* boxes.
6. Click *Save*. 

You should see an alert message: _File e:\dev\MyApp\MyApp.exe successfully created._

T> Use the *Version* button to bind to the EXE information about the application, author, version, copyright and so on. Specify an icon file to replace the Dyalog icon with one of your own. 

Let's run it. From a command line:

~~~
e:\Users\A.N. Other>CD e:\dev
e:\dev>MyApp\MyApp.exe texts\en
~~~

Looking at `e:\dev\texts\en.csv` in Windows Explorer, we see its timestamp just changed. Our EXE works! 

