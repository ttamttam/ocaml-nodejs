These are [js\_of\_ocaml](https://github.com/ocsigen/js_of_ocaml) bindings to [nodejs](https://github.com/nodejs/node)

Get all the power of the amazing `node` ecosystem with the sanity and
type safety of `OCaml`.

```shell
$ opam install nodejs
```

Working Chat Server
![img](./node_server_working.gif)

Here's the example's source code: which is located along side its
dependencies and make file in the `examples` directory.

```ocaml
(* Basically a translation of
   http://arminboss.de/2013/tutorial-how-to-create-a-basic-chat-with-node-js/ *)
let program () =
  let http = Nodejs.Http.require () in
  let fs = Nodejs.Fs.require () in
  let io = Socket_io.require () in

  let port = 8080 in
  let headers = Nodejs.js_object_of_alist [("Content-Type", "text/html")] in
  let server =
    http##createServer (Js.wrap_callback begin
        fun request response ->
          fs##readFile (Js.string "./client.html")
            (Js.wrap_callback begin fun error raw_data ->
                response##writeHead 200 headers;
                response##end_data raw_data
              end)
      end)
  in
  let app = server##listen port
    begin Js.wrap_callback begin fun () ->
        Printf.sprintf
          "\n\nStarted Server on local host port %d, node version: %s"
          port
          Nodejs.version
        |> print_endline
      end
    end
  in
  let io = io##listen app in
  (* Gives back a namespace object *)
  io##.sockets##on
    (Js.string "connection")
    (* And now we get a socket *)
    (Js.wrap_callback begin fun socket ->
        socket##on
          (Js.string "message_to_server")
          (* For which we have some data, its an object *)
          (Js.wrap_callback begin fun data ->
              let innard = Js.Unsafe.get data "message" in
              io##.sockets##emit
                (Js.string "message_to_client")
                (Nodejs.js_object_of_alist [("message", innard)])
            end)
      end)

let run p =
  ignore (p ())

let () =
  run program
```

# Steps to get the example working

I assume that you have `opam`, `js_of_ocaml` and of course `node`
installed. Until I get this all on `opam` you'll need to do the
following steps.

1.  Get the `nodejs` package installed on your machine.

```shell
$ opam install nodejs
```

1.  Get the `socket_io` package installed on your machine.

```shell
$ git clone https://github.com/fxfactorial/ocaml-npm-socket-io
$ cd ocaml-npm-socket-io
$ opam pin add socket_io . -y
```

1.  Compile `chat_server.ml` into a working `node` program. Note that
    this will install a local node module, the `socket.io` module.

```shell
$ cd examples
$ make
```

and open up localhost:8080, you'll have a working `node` server.

(Note that you'll only need to call `make` once, afterwards you can
directly just invoke node with `node chat_server.js`.)

# Issues

1.  `node` has a pretty big API so its going to take me a little bit of
    time to cover the API and the bindings that I'm also writing for
    `express` and `socket.io`
2.  `JavaScript`
