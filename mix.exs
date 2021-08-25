defmodule PlugSocket.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/kevinlang/plug_socket"

  def project do
    [
      app: :plug_socket,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "PlugSocket",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Kevin Lang"],
      links: %{"GitHub" => @url}
    }
  end

  defp deps do
    []
  end
end
