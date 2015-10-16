let () =
  let http = Nodejs.Http.require () in
  let fs = Nodejs.Fs.require () in
  let port = 8080 in
  let headers = Nodejs.js_object_of_alist [("Content-Type", "text/html")] in
  let server =
    http##createServer_with_callback (Js.wrap_callback begin
        fun request response ->
          fs##readFile (Js.string "_oasis")
            (Js.wrap_callback begin fun error raw_data ->
                print_endline (Js.to_string raw_data);
                response##writeHead 200 headers;
                response##end_ (Js.string "I can't belive this works")
              end)
      end)
  in
  server##listen port
    begin Js.wrap_callback begin fun () ->
        print_endline ("Started server!, running version " ^ Nodejs.version);
      end
    end

(* let express = Express.require () *)
(* let app = Express.make_app () *)
(* let server = (Nodejs.Http.require ())##createServer app *)
