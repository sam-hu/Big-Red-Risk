# Big Red R!sk!
A Risk board game with AI implemented in OCaml and an external python GUI API.  
*Authors: Sam Hu, Prathamesh Bang, Ohad Koronyo, Imani Chilongani*

Developed at Cornell's CS 3110 Course

How to Run This Program
--------------------------------------------------------------------------------
This game requires the Lymp external library, which allows python functions and
objects to be used with OCaml. More information about Lymp can be found at the
following link:

  https://github.com/dbousque/lymp

To use Lymp, you must have OCaml as well as Python 2 or 3 installed on your 
machine. Run the following command on your terminal to install Lymp:
```
  opam update && opam install lymp
```
From the Lymp readme:
>"Python's pymongo package is required (for it's bson subpackage), opam and the
>Makefile. Try to install it using pip and pip3, so you should not have to install
>it manually. If ```$ python3 -c "import pymongo"``` fails, you need to install
>pymongo, maybe using sudo on pip or pip3."

Once Lymp is installed, run the following command from the directory containing
the source files for the game (and probably this document):
```
  make play
```
Once the game initializes, you will be prompted by the terminal to input how
many total players you would like to be in the game, how many of those
players you would like to be controlled by an AI, and how aggressive you would
like those AI's to be.

Known Issues
--------------------------------------------------------------------------------
Lymp compiles best on the newest MacOS. It doesn't cooperate with Windows or the
VM. It may be worth noting that this game has only been proven to run on Mac.
