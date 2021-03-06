(* Basically a translation of
   http://arminboss.de/2013/tutorial-how-to-create-a-basic-chat-with-node-js/ *)
open Nodejs

let () =
  let io = Socket_io.require () in
  let server =
    Http.create_server begin fun incoming response ->

      Fs.read_file ~path:"./client.html" begin fun err data ->
        response#write_head ~status_code:200 [("Content-type", "text/html")];
        response#end_ ~data:(String data) ()

      end
    end
  in
  let app = server#listen ~port:8080 begin fun () ->

      let s =
        Printf.sprintf "Started Server and Running node: %s" (new process#version)
      in

      Colors_js.colorize ~msg:s ~styles:[Colors_js.Cyan_bg; Colors_js.Inverse] []
      |> print_endline

    end
  in

  let io = io#listen app in
  io#sockets#on_connection begin fun socket ->

    socket#on "message_to_server" begin fun data ->

      io#sockets#emit
        ~event_name:"message_to_client"
        !!(object%js val message = data <!> "message" end)

    end
  end
