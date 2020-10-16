defmodule Coingecko.MixProject do
  use Mix.Project

  @source_url "https://github.com/steffenix/coingecko"

  def project do
    [
      app: :coingecko,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Coingecko.Application, []}
    ]
  end

  defp deps do
    [
      {:cachex, "~> 3.3"},
      {:mojito, "~> 0.7.3"},
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Elixir API wrapper for CoinGecko to fetch crypto currencies prices."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "Coingecko",
      source_url: @source_url
    ]
  end
end
