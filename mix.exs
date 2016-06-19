defmodule Cdn.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :cdn,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ex_aws, :httpoison]]
  end

  defp deps do
    [
      {:ex_aws,    "~> 0.4.10"},
      {:poison,    "~> 1.2"},
      {:httpoison, "~> 0.7"},
      {:sweet_xml, "~> 0.6.1"},
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
