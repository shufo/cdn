defmodule CdnTest do
  use ExUnit.Case, async: true
  doctest Cdn.S3
  doctest Cdn.Helpers
  doctest Cdn.File
  doctest Cdn.Utils

  test "the truth" do
    assert 1 + 1 == 2
  end
end
