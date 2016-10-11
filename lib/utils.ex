defmodule Cdn.Utils do
  @moduledoc false

  @doc ~S"""
   Returns ISO 8601 DateTime as Unixtime.

  ## Examples

    iex> Cdn.Utils.iso_z_to_secs("2016-06-19T12:00:00Z")
    1466337600

    iex> Cdn.Utils.iso_z_to_secs("2016-06-19T13:00:00.000Z")
    1466341200

  """
  @spec iso_z_to_secs(binary) :: integer
  def iso_z_to_secs(<<date::binary-10, "T", time::binary-8, ".", _millisecond::binary-3, "Z">>), do: iso_z_to_secs("#{date}T#{time}Z")
  def iso_z_to_secs(<<date::binary-10, "T", time::binary-8, "Z">>) do
    <<year::binary-4, "-", mon::binary-2, "-", day::binary-2>> = date
    <<hour::binary-2, ":", min::binary-2, ":", sec::binary-2>> = time
    year = year |> String.to_integer
    mon  = mon  |> String.to_integer
    day  = day  |> String.to_integer
    hour = hour |> String.to_integer
    min  = min  |> String.to_integer
    sec  = sec  |> String.to_integer

    {{year, mon, day}, {hour, min, sec}}
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.-(:calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}))
  end

  @doc """
    Console color (blue)
  """
  def blue do
    "\u001b[34m"
  end

  @doc """
    Reset code for console color
  """
  def reset do
    "\u001b[0m"
  end
end
