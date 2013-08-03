Low Level Classes (LLClasses)
=============================

Description
-----------

LLClasses is a collection of classes for the D programming language.
It's based around a previous work called 'Unmanaged'.

Features
--------

- Win/Posix.
- internally the GC footprint is minimized when possible.
- template to avoid GC collection of classes.
- two easy to use lists.
- standard streams (memory/file/volume).
- serialization system, implementable via an interface.
- property descriptors (user-defined RTTI).
- a property binder.
- a collection system with automatic serialization.

Setup
-----

Under Windows, compile the library by running the *.bat scripts located in
the folder 'BuildScripts'. Under Linux, run the *.sh scripts in a terminal.

Notes
-----

- tested under Linux x86_64 and Win32.
- examples are (currently) Win only.