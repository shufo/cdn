defmodule Cdn.Helpers do
  @moduledoc false

  @doc ~S"""
   Generate static file path.

  ## Examples

    iex> Application.put_env(:cdn, :bypass, true)
    iex> Cdn.Helpers.cdn("/css/app.css")
    "/css/app.css"

    iex> Cdn.Helpers.cdn("/css/app.css", true)
    "/css/app.css"

    iex> Application.put_env(:cdn, :cloudfront_url, "http://cdn.example.com")
    ...> Cdn.Helpers.cdn("/css/app.css", false)
    "http://cdn.example.com/css/app.css"

    iex> Cdn.Helpers.cdn("/css/app.css", true, "https://cloudfront.net")
    "/css/app.css"

    iex> Cdn.Helpers.cdn("/css/app.css", false, "https://cloudfront.net")
    "https://cloudfront.net/css/app.css"

    iex> Application.put_env(:cdn, :bypass, false)
    iex> Application.put_env(:cdn, :cloudfront_url, "http://example.cloudfront.net")
    ...> Cdn.Helpers.cdn("/css/app.css")
    "http://example.cloudfront.net/css/app.css"
  """
  def cdn(path), do: cdn(path, bypass?)
  def cdn(path, true = _bypass, _host), do: "#{path}"
  def cdn(path, false = _bypass, host), do: "#{host}#{path}"
  def cdn(path, nil = _bypass), do: path
  def cdn(path, true = _bypass), do: path
  def cdn(path, false = _bypass), do: "#{Application.get_env(:cdn, :cloudfront_url)}#{path}"

  defp bypass?, do: Application.get_env(:cdn, :bypass)


end
