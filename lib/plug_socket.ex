defmodule PlugSocket do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :plug_sockets, accumulate: true)
      import PlugSocket
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __plug_sockets__(), do: @plug_sockets
    end
  end

  @doc """
  Registers a socket that is associated with the module.

  The `module` must implement the `:cowboy_websocket_handler` behavior.

  ## Example

      defmodule MyApp do
        use PlugSocket

        socket "/my-socket", MyApp.MySocket
      end
  """
  defmacro socket(path, module, opts \\ []) do
    quote do
      @plug_sockets {unquote(path), unquote(module), unquote(opts)}
    end
  end

  @doc """
  Generates the dispatch options for `Plug.Cowboy`.

  Note that when using this custom dispatch, if you want to pass along opts
  to your plug, you must pass them as the second argument here, and not
  pass them along via the `:plug` key in the `Plug.Cowboy` child spec
  directly.

  ## Example

      children = [
        {Plug.Cowboy,
         scheme: :http,
         plug: MyApp,
         options: [
           dispatch: PlugSocket.plug_cowboy_dispatch(MyApp)
         ]}
      ]

      Supervisor.start_link(children, strategy: :one_for_one)

  """
  def plug_cowboy_dispatch(plug, plug_opts \\ []) do
    plug_cowboy_handler = [{:_, Plug.Cowboy.Handler, {plug, plug_opts}}]
    socket_handlers = Enum.reverse(plug.__plug_sockets__())

    [
      {:_, socket_handlers ++ plug_cowboy_handler}
    ]
  end
end
