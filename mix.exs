defmodule Coingecko.MixProject do
  use Mix.Project

  def project do
    [
      app: :coingecko,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Coingecko.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cachex, "~> 3.3"},
      {:mojito, "~> 0.7.3"},
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Coingeko API wrapper to fetch crypto currencies prices."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "coingecko",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/steffenix/coingecko"}
    ]
  end
end
