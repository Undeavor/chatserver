# chatserver
Chat TCP server in OCaml using Lwt

So, it has basic commands and works via telnet in localhost and port 9000 ( you can modify it ).

### Requirements
- "brew install opam"/"apt install opam", depending on MacOS or Linux
- "opam init", follow the instructions ( i usually type "N" then "y" )
- "eval $(opam env)"
- "opam install lwt logs dune"

### Installation with new project 
- "dune init project ChatServer"
- "cd Chatserver"
- "nano bin/main.ml" > copy/paste the code inside bin/main.ml here
- "nano bin/main.ml" > copy/paste the code inside bin/dune here

### ID/PASSWD
-inside of the main.ml code, they are static so you have to add them before running the server

### Compile & Run
- don't forget to run "eval $(opam env)" before using any command with opam/dune
- "dune build bin/main.exe --profile release", the last arg is here to bypass warnings when compiling
- "dune exec /PATH_TO_PROJECT/_build/default/bin/main.exe", it runs the server
- on another terminal/machine "telnet IP PORT" et voilà !

### Commands : all have a confirmation message
- inc : increase the counter (to verify if the server is running properly)
- ver : verify the counter
- msg USERNAME PASSWORD MESSAGE : release an identified message but if you miss your id/password, the terminal session you are in crashes
- read : print all the messages from the starting of the server
If a command doesn't respond, your session has crashed so open another terminal window and try with a different command.

### Via cellphone: different options
- use Terminal# on Iphone to connect via shh to the server ( if it's a client, you must attribute him a user/passwd ) then run telnet 
- use Termiux on Android to connect via telnet directly
