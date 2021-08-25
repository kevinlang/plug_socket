defmodule PlugSocketTest do
  use ExUnit.Case, async: true

  doctest PlugSocket

  setup do
    :code.purge(PlugSocketTest.Example)
    :code.purge(PlugSocketTest.Example.Socket)
    :code.delete(PlugSocketTest.Example)
    :code.delete(PlugSocketTest.Example.Socket)
    :ok
  end

  test "dispatch is correct" do
    defmodule Example do
      defmodule Socket do
      end

      use PlugSocket

      socket("/ws", Socket)
      socket("/ws2", Socket, my: "opt")
    end

    assert PlugSocket.plug_cowboy_dispatch(Example) == [
             {:_,
              [
                {"/ws", Example.Socket, []},
                {"/ws2", Example.Socket, [my: "opt"]},
                {:_, Plug.Cowboy.Handler, {Example, []}}
              ]}
           ]
  end

  test "dispatch handles no socket case" do
    defmodule Example do
      use PlugSocket
    end

    assert PlugSocket.plug_cowboy_dispatch(Example) == [
             {:_,
              [
                {:_, Plug.Cowboy.Handler, {Example, []}}
              ]}
           ]
  end

  test "dispatch handles plug opts" do
    defmodule Example do
      defmodule Socket do
      end

      use PlugSocket

      socket("/ws", Socket)
    end

    assert PlugSocket.plug_cowboy_dispatch(Example, my: "opt") == [
             {:_,
              [
                {"/ws", Example.Socket, []},
                {:_, Plug.Cowboy.Handler, {Example, [my: "opt"]}}
              ]}
           ]
  end
end
