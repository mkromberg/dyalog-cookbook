{:: encoding="utf-8" /}

# Introduction

You want to write an application in Dyalog APL. You have already learned enough of the language to put some of your specialist knowledge into functions you can use in your work. The code works for you. Now you want to turn it into an application others can use. Perhaps even sell it. 

This is where you need professional programming skills. How to install your code into an unknown computer. Have it catch, handle and log errors. Manage the different versions of your software as it evolves. Provide online help. 

You are not a professional programmer. You don't have those skills. Perhaps you need a professional programmer to turn your code into an application. But you've come a long way already. Perhaps you can get there by yourself - with the Dyalog Cookbook. 

The Dyalog Cookbook is about how to turn your Dyalog code into an application. We'll cover packaging your code into a robust environment. And we'll introduce some software development tools you've managed without so far, which will make your life easier.

You might continue as the sole developer of your app[^app] for a long time yet. But if your app becomes a successful product you will eventually want other programmers collaborating on it. So we'll set up your code in a source-control system that will accommodate that. Even while you remain a sole developer, a source-control system will also allow you to roll back and recover from your own mistakes. 

Not so long ago it was sufficient for an app to be packaged as an EXE that could be installed and run on other PCs. Nowadays many corporate clients run apps in terminal servers or in private clouds. So we'll look at how to organise your app to run as tasks that communicate with each other. Many apps written in Dyalog focus on some kind of numerical analysis, and can have CPU-intensive tasks. We'll look at how such tasks can be packaged to run either in background or on remote machines. 

W> Many of these issues are entangled with each other. We’ll arrive at the best solutions by way of some interim solutions, so you get to understand on the way the issues and how their solutions work. In Part 1 you will find ‘framework’ code for your application, growing more complex as the book progresses. You can find scripts for these interim versions on the book website at dyalog.com. Watch out: they are interim solutions. By all means adapt the last as a framework for your application, but do so knowing how it works! 

Finally in Part 2 we'll introduce some professional writing techniques that might make maintaining your code easier – in what we hope will be a long useful future for it! 

## What you need to use the Dyalog Cookbook

* The Dyalog Version 14 Unicode interpreter or later.
* To know how to use namespaces, classes and instances. Much of the utility code in the Cookbook is packaged into classes. This is the form in which it is easiest for you to slide the code into your app without name conflicts. We recommend you use classes to organise your own code! But even if you don't, you need to know at least how to use classes. This is a deep subject, but all you need to know is the basics: creating an instance of a class and using its methods and properties, or just using the methods of a static class. See <cite>Dyalog Programmer's Reference Guide</cite> for an introduction. 
* To know how to use SALT, the Simple APL Library Toolkit. Just the basics, including editing namespace and class scripts. See <cite>Dyalog SALT Reference Guide</cite>.


Stephen Taylor & Kai Jaeger

[^app]: In this book _app_ and _application_ mean the same thing.