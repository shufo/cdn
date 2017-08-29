defmodule Cdn.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [app: :cdn,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ex_aws, :httpoison, :mime, :calendar]]
  end

  defp deps do
    [
      {:ex_aws,    "~> 1.0.0"},
      {:httpoison, ">= 0.0.0", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},
      {:ex_doc, "~> 0.12", only: :dev},
      {:mime, "~> 1.0"},
      {:calendar, "~> 0.16.1"},
    ]
  end

  defp description do
    """
    Content Delivery Network Package for Elixir
    """
  end

  defp package do
    [name: :cdn,
     files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Shuhei Hayashibara"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/shufo/cdn"}]
  end
end
