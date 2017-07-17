defmodule Iona.Mixfile do
  use Mix.Project

  def project do
    [app: :iona,
     version: "0.2.1",
     elixir: "~> 1.4",
     source_url: "https://github.com/CargoSense/iona",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [flags: "--fullpath"],
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :briefly, :porcelain],
     mod: {Iona, []},
     env: default_env()]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.8", only: :dev},
     {:briefly, "~> 0.3"},
     {:porcelain, "~> 2.0"}]
  end

  defp package do
    [description: "Document generation using LaTeX",
     files: ["lib", "config", "mix.exs", "README*", "LICENSE"],
     contributors: ["Bruce Williams"],
     licenses: ["Apache 2"],
     links: %{github: "https://github.com/CargoSense/iona"}]
  end

  defp default_env do
    [preprocess: [],
     processors: [pdf: "pdflatex", dvi: "latex"],
     helpers: [Iona.Template.Helper]]
  end

end
