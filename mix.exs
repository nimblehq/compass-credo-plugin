defmodule CompassCredoPlugin.MixProject do
  use Mix.Project

  def project do
    [
      app: :compass_credo_plugin,
      description: "Credo custom checks plugin to comply with Nimble Compass conventions",
      package: package(),
      version: "0.1.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        lint: :test,
        coverage: :test,
        coveralls: :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/nimblehq/compass-credo-plugin"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      coverage: ["coveralls.html --raise"],
      codebase: [
        "credo --strict",
        "deps.unlock --check-unused",
        "format --check-formatted"
      ],
      "codebase.fix": [
        "deps.clean --unlock --unused",
        "format"
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6.6", [only: [:dev, :test]]},
      {:dialyxir, "~> 1.2.0", [only: [:dev], runtime: false]},
      {:excoveralls, "~> 0.14.6", [only: :test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:faker, "~> 0.17.0", [only: [:dev, :test], runtime: false]}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nimblehq/compass-credo-plugin"}
    ]
  end
end
