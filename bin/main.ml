open Lwt
open Lwt_io
open Stdlib
open Str
open Unix

(* Shared mutable counter *)
let counter = ref 0
(* let message = ref ["shesh", "sheesh"] *)
let message = ref ["blank"]

let listen_address = Unix.inet_addr_loopback
let port = 9000
let backlog = 10

let starts_with_msg str =
    let prefix = String.sub str 0 4 in
    prefix = "msg "

(* Politique de mdp, 8chars *)
let starts_with_auth str =
    let users =
        ["duke duknukem"
        ; "flavien flavouil"
        ; "bilel bouzouga"
        ; "tanguy bougboug"]
    in
    let rec check_prefix_with_users user_list =
    match user_list with
    | [] -> "unknown"  (* Base case: No user prefix matches *)
    | user :: rest_users ->
        let prefix = String.sub str 0 (String.length user) in
        if prefix = user then
            prefix  (* String starts with a user's prefix *)
        else
            check_prefix_with_users rest_users
    in
    check_prefix_with_users users


let extract_without_msg_prefix str =
    if String.length str > 4 && String.sub str 0 4 = "msg " then
        let string = String.sub str 4 (String.length str - 4) in 
        string
    else
        str

let split_string str =
    let delimiter = " " in
    Str.split (Str.regexp delimiter) str

let trim_id str =
    let length = String.length str in
    if length <= 9 then
        ""
    else
        String.sub str 0 (length - 9)

let handle_message msg =
    match msg with
    | "cmd" -> "msg USERNAME PASSWORD MESSAGE : release an identified message but if you miss your password, your terminal session crashes\nver : verify the counter \ninc : increase the counter \nread : print all the messages from the starting of the server"
    | "ver" -> string_of_int !counter
    | "read"  -> let formatted_string = String.concat "\n" !message in formatted_string
    | "inc"  -> counter := !counter + 1; "Counter has been incremented"
    | "quit" -> "You cant escape me. I'm in your room. Check behind you."
    | _      -> "Unknown command, type cmd the nomenclature"

let rec handle_connection ic oc () =
    Lwt_io.read_line_opt ic >>=
    (fun msg ->
        match msg with
        | Some msg ->
            if String.length msg > 4 && starts_with_msg msg then
                let subcommand = extract_without_msg_prefix msg in
                let id = starts_with_auth subcommand in
                let final_msg = 
                    if id <> "unknown" then
                        let number = String.length id in
                        let string = String.sub subcommand number (String.length subcommand - number) in 
                        String.trim string
                    else
                        subcommand
                    in
                let final_id = 
                    if id <> "unknown" then
                        trim_id id
                    else 
                        subcommand
                    in
                let current_time = Unix.localtime (Unix.time ()) in
                let formatted_time =
                    Printf.sprintf "%02d:%02d:%02d %02d/%02d/%04d"
                      current_time.tm_hour current_time.tm_min current_time.tm_sec
                      (current_time.tm_mon + 1) current_time.tm_mday (current_time.tm_year + 1900) in
                let reversed_list = List.rev !message in
                let reversed_message = (formatted_time ^ " " ^ "[" ^ final_id ^ "]" ^ " " ^ final_msg) :: reversed_list in
                message := List.rev reversed_message;
                Lwt_io.write_line oc "message released in da hood" >>= handle_connection ic oc
            else
                let reply = handle_message msg in
                Lwt_io.write_line oc reply >>= handle_connection ic oc
        | None -> Logs_lwt.info (fun m -> m "Connection closed") >>= return)

let accept_connection conn =
    let fd, _ = conn in
    let ic = Lwt_io.of_fd Lwt_io.Input fd in
    let oc = Lwt_io.of_fd Lwt_io.Output fd in
    Lwt.on_failure (handle_connection ic oc ()) (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e)));
    Logs_lwt.info (fun m -> m "New connection") >>= return
 
let create_socket () =
    let open Lwt_unix in
    let sock = socket PF_INET SOCK_STREAM 0 in
    bind sock @@ ADDR_INET(listen_address, port);
    listen sock backlog;
    sock

let create_server sock =
    let rec serve () =
        Lwt_unix.accept sock >>= accept_connection >>= serve
    in serve

let () =
    let () = Logs.set_reporter (Logs.format_reporter ()) in
    let () = Logs.set_level (Some Logs.Info) in
    let sock = create_socket () in
    let serve = create_server sock in
    Lwt_main.run @@ serve () 



