# PlugSocket

[Online Documentation](https://hexdocs.pm/plug_socket).

<!-- MDOC !-->

Enables a convenient way of specifying sockets within your `Plug.Router`.

`PlugSocket` is not a `Plug` itself. Instead, it provides a convenient
DSL for specifying any sockets as part of your `Plug.Router` that can
later be added to the `Plug.Cowboy` adapter.

Because it is not tied to `Plug` or `Plug.Router` directly, it can also be
used independently of Plug, if one wants to just use `Cowboy` directly.

## Usage

Add the `PlugSocket` to your router. E.g.,

    defmodule MyApp.Router do
      use Plug.Router

      socket "/my-socket", MyApp.MySocket

      plug :match
      plug :dispatch

      get "/" do
        send_resp(conn, 200, "hello world")
      end
    end

Each `module` you pass to `socket/3` must implement the `:cowboy_websocket_handler`
behavior. Note that because `socket/3` is _not_ a `Plug`, it is not part of any
plug pipeline you create in your router.

Next, you need to ensure our websockets are added to the `Cowboy` dispatch:

    def start(_type, _args) do
      children = [
        {Plug.Cowboy, scheme: :http, plug: MyApp.Router, options: [
          dispatch: PlugSocket.plug_cowboy_dispatch(MyApp.Router)
        ]}
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start_link(children, opts)
    end

This registers your sockets with the Cowboy dispatcher. You can now
start the application and navigate to your socket path in your client
and see that it is now routing!
