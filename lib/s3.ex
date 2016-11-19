defmodule Cdn.S3 do
  @moduledoc false

  require Logger
  import Cdn.Utils
  import MIME, only: [from_path: 1]

  @doc """
    Lists all files in `bucket`.
  """
  @spec list_files_already_on_bucket(binary) :: Keyword.t
  def list_files_already_on_bucket(bucket) do
    case ExAws.S3.list_objects(bucket) |> ExAws.request do
      {:ok, response} ->
        response
        |> get_in([:body, :contents])
        |> Enum.map(&({:"#{&1.key}", &1}))
        _ -> raise "List S3 files error"
    end
  end

  @doc """
    Put `assets` files into `bucket`.
  """
  @spec put_objects(List.t, binary) :: atom
  def put_objects(assets, bucket) do
    Logger.info "#{blue}Uploading files...#{reset}"
    assets
    |> Enum.each(&(put_object(&1, bucket)))
    Logger.info "#{blue}Upload finished.#{reset}"
  end

  @doc """
    Put a `asset` into `bucket`.
  """
  def put_object({_, asset}, bucket) do
    Logger.info "Uploading file path: #{asset.path}"
    ExAws.S3.put_object(bucket, asset.path, File.read!(asset.original), object_headers(asset.path)) |> ExAws.request
  end

  @doc ~S"""
   Return mime type from file path

  ## Examples

    iex> Cdn.S3.object_headers("uploads/s3.jpg")
    [
      acl: Application.get_env(:cdn, :acl),
      cache_control: Application.get_env(:cdn, :cache_control),
      expires: Calendar.DateTime.now_utc
              |> Calendar.DateTime.add!(Application.get_env(:cdn, :expires_after))
              |> Calendar.DateTime.Format.httpdate,
      content_type: "image/jpeg",
    ]

  """
  def object_headers(path) do
    Keyword.merge(s3_options, content_type: content_type(path))
  end

  @doc ~S"""
   Return mime type from file path

  ## Examples

    iex> Cdn.S3.content_type("uploads/s3.jpg")
    "image/jpeg"

    iex> Cdn.S3.content_type("test/fixtures/mtime.txt")
    "text/plain"

  """
  def content_type(path) do
    from_path(path)
  end

  @doc """
    Delete assets in `bucket`'s `asset_path`.
  """
  def delete_objects(bucket) do
    Logger.info "#{blue}Deleting file from bucket...#{reset}"

    objects = all_objects(bucket)

    Enum.each(objects, &(Logger.info "Delete object key: #{&1}"))

    objects
    |> Enum.chunk(1000, 1000, [])
    |> Enum.each(&delete_multiple_objects(bucket, &1))

    Logger.info "#{blue}Delete finished.#{reset}"
  end

  defp delete_multiple_objects(bucket, objects) do
    ExAws.S3.delete_multiple_objects(bucket, objects) |> ExAws.request
  end

  @doc """
    Returns all object's key in `bucket`
  """
  def all_objects(bucket) do
    list_files_already_on_bucket(bucket)
    |> Keyword.keys
    |> Enum.map(&(&1 |> to_string))
  end

  @doc """
    Delete a `asset` in `bucket`.
  """
  def delete_object(bucket, {_, asset}) do
    Logger.info "Deleting file path: #{asset.key}"
    ExAws.S3.delete_object(bucket, asset.key) |> ExAws.request
  end

  @doc ~S"""
   Return true if asset is in specified path

  ## Examples

    iex> Cdn.S3.asset_file?({:"path", %{key: "uploads/s3.jpg"}}, "priv/static")
    false

    iex> Cdn.S3.asset_file?({:"path", %{key: "priv/static/s3.jpg"}}, "priv/static")
    true

  """
  def asset_file?({_, asset} = _target, asset_path) do
    asset.key
    |> String.starts_with?(asset_path)
  end

  @doc ~S"""
   Generate s3 options

  ## Examples

    iex> Cdn.S3.s3_options
    [
      acl: Application.get_env(:cdn, :acl),
      cache_control: Application.get_env(:cdn, :cache_control),
      expires: Calendar.DateTime.now_utc
              |> Calendar.DateTime.add!(Application.get_env(:cdn, :expires_after))
              |> Calendar.DateTime.Format.httpdate
    ]

  """
  def s3_options do
    [
      acl: Application.get_env(:cdn, :acl),
      cache_control: Application.get_env(:cdn, :cache_control),
      expires: expires
    ]
  end

  # Returns expires field in RFC2616 format
  defp expires do
    Calendar.DateTime.now_utc
    |> Calendar.DateTime.add!(Application.get_env(:cdn, :expires_after))
    |> Calendar.DateTime.Format.httpdate
  end
end
