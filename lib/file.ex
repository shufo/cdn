defmodule Cdn.File do
  @moduledoc false

  @doc ~S"""
   Recursively lists all files that is in `dir` directory.
   Returns keyword lists of `{:path, file_stat}`

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Application.put_env(:cdn, :exclude, [directories: []])
    ...> Cdn.File.list_files_in_local
    ["test/fixtures/mtime.txt": %{mtime: Cdn.File.mtime("test/fixtures/mtime.txt"),
              original: "test/fixtures/mtime.txt",
              path: "mtime.txt", size: 5},
            "test/fixtures/sub/test.txt": %{mtime: Cdn.File.mtime("test/fixtures/sub/test.txt"),
              original: "test/fixtures/sub/test.txt",
              path: "sub/test.txt", size: 7}]

  """
  def list_files_in_local do
    include_files
    |> Enum.reject(&exclude?(&1))
    |> Enum.map(&({:"#{&1}", file_stat(&1)}))
  end

  @doc ~S"""
   Return `true` if `path` matches the exclude pattern

  ## Examples

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures"], patterns: ["**/*.txt"]])
    ...> Cdn.File.exclude?("test/fixtures/sub/test.txt")
    true

  """
  def exclude?(path) do
    path in exclude_files
  end

  @doc ~S"""
   Return include files in list

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.include_files
    ["test/fixtures/mtime.txt", "test/fixtures/sub/test.txt"]


  """
  def include_files do
    include_glob_patterns
    |> Enum.flat_map(&(Path.wildcard(&1, match_dot: include_hidden?)))
    |> Enum.filter(&regular_file?(&1))
  end

  defp include_hidden? do
    Application.get_env(:cdn, :include)[:hidden]
  end

  @doc ~S"""
   Return include glob patterns

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.include_glob_patterns
    ["test/fixtures/**/*"]

  """
  def include_glob_patterns do
    include_directories
    |> Enum.map(&Enum.map(include_patterns, fn(x) -> "#{&1}/#{x}" end ))
    |> List.flatten
    |> Enum.uniq
  end

  @doc ~S"""
   Returns include directories

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.include_directories
    ["test/fixtures"]

  """
  def include_directories do
    Application.get_env(:cdn, :include)[:directories]
  end

  @doc ~S"""
   Returns include patterns

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.include_patterns
    ["**/*"]

  """
  def include_patterns do
    Application.get_env(:cdn, :include)[:patterns]
  end

  @doc ~S"""
   Returns excluded files in list

  ## Examples

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.exclude_files
    ["test/fixtures/mtime.txt", "test/fixtures/sub/test.txt"]

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures/sub"], patterns: ["**/*"]])
    ...> Cdn.File.exclude_files
    ["test/fixtures/sub/test.txt"]

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures"], patterns: ["sub/*"]])
    ...> Cdn.File.exclude_files
    ["test/fixtures/sub/test.txt"]

  """
  def exclude_files do
    exclude_glob_patterns
    |> Enum.flat_map(&(Path.wildcard(&1, match_dot: exclude_hidden?)))
    |> Enum.filter(&regular_file?(&1))
  end

  defp exclude_hidden? do
    Application.get_env(:cdn, :exclude)[:hidden]
  end

  @doc ~S"""
   Return excluded glob patterns

  ## Examples

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.exclude_glob_patterns
    ["test/fixtures/**/*"]

    iex> Application.put_env(:cdn, :exclude, [directories: ["test/fixtures"], patterns: ["**/*.jpg"]])
    ...> Cdn.File.exclude_glob_patterns
    ["test/fixtures/**/*.jpg"]

  """
  def exclude_glob_patterns do
    exclude_directories
    |> Enum.map(&Enum.map(exclude_patterns, fn(x) -> "#{&1}/#{x}" end ))
    |> List.flatten
    |> Enum.uniq
  end

  @doc ~S"""
   Returns excluded directory

  ## Examples

    iex> Application.put_env(:cdn, :exclude, [directories: ["priv/static"]])
    ...> Cdn.File.exclude_directories
    ["priv/static"]

  """
  def exclude_directories do
    Application.get_env(:cdn, :exclude)[:directories]
  end

  @doc ~S"""
   Returns excluded patterns

  ## Examples

    iex> Application.put_env(:cdn, :exclude, [patterns: ["**/*.js"]])
    ...> Cdn.File.exclude_patterns
    ["**/*.js"]

  """
  def exclude_patterns do
    Application.get_env(:cdn, :exclude)[:patterns]
  end
  @doc ~S"""
   Returns file stat of `path`

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["test/fixtures"], patterns: ["**/*"]])
    ...> Cdn.File.file_stat("test/fixtures/mtime.txt")
    %{path: "mtime.txt", original: "test/fixtures/mtime.txt",
      mtime: Cdn.File.mtime("test/fixtures/mtime.txt"), size: 5}

  """
  def file_stat(path) do
    %{path: strip_path(path), original: path, mtime: mtime(path), size: size(path)}
  end

  @doc ~S"""
   Strip asset directory prefix

  ## Examples

    iex> Application.put_env(:cdn, :include, [directories: ["priv/static"], patterns: ["**/*"]])
    ...> Cdn.File.strip_path("priv/static/js/app.js")
    "js/app.js"

    iex> Application.put_env(:cdn, :include, [directories: ["priv/static"], patterns: ["**/*"]])
    ...> Cdn.File.strip_path("priv/static/css/app.css")
    "css/app.css"

  """
  def strip_path(path) do
    Application.get_env(:cdn, :include)[:directories]
    |> Enum.filter(&String.starts_with?(path, &1))
    |> Enum.sort(&(byte_size(&1) <= byte_size(&2)))
    |> List.first
    |> _strip_path(path)
  end

  defp _strip_path(nil = _strip, path), do: path
  defp _strip_path(strip, path) do
    String.replace_prefix(path, strip, "")
    |> String.replace_prefix("/", "")
  end

  @doc ~S"""
   Get last modified time of specified path.

  ## Examples

    iex> Cdn.File.mtime("test/fixtures/mtime.txt")
    Cdn.File.mtime("test/fixtures/mtime.txt")

  """
  def mtime(path) do
    case File.stat(path) do
      {:ok, %File.Stat{mtime: mtime}} ->
        mtime
        |> :calendar.datetime_to_gregorian_seconds
        |> Kernel.-(:calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}))
      _ -> raise "stat error"
    end
  end

  @doc ~S"""
   Get byte size of specified path.

  ## Examples

    iex> Cdn.File.size("test/fixtures/mtime.txt")
    5

  """
  def size(path) do
    case File.stat(path) do
      {:ok, %File.Stat{size: size}} -> size
      _ -> raise "stat error"
    end
  end

  @doc ~S"""
   Returns `true` if specified `path` is a regular file.

  ## Examples

    iex> Cdn.File.regular_file?("text/fixtures")
    false

    iex> Cdn.File.regular_file?("test/fixtures/mtime.txt")
    true

  """
  def regular_file?(path) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular}} -> true
      _ -> false
    end
  end
end
