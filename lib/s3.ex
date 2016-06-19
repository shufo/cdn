defmodule Cdn.S3 do
  @moduledoc false

  require Logger
  import Cdn.Utils

  @doc """
    Lists all files in `bucket`.
  """
  @spec list_files_already_on_bucket(binary) :: Keyword.t
  def list_files_already_on_bucket(bucket) do
    case ExAws.S3.list_objects!(bucket) do
      %{body: %{contents: contents}} ->
        contents
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
    ExAws.S3.put_object!(bucket, asset.path, File.read!(asset.original), s3_options)
  end

  @doc """
    Delete assets in `bucket`'s `asset_path`.
  """
  def delete_objects(bucket) do
    Logger.info "#{blue}Deleting file from bucket...#{reset}"
    objects = all_objects(bucket)
    Enum.each(objects, &(Logger.info "Delete object key: #{&1}"))
    {:ok, _} = ExAws.S3.delete_all_objects(bucket, objects)
    Logger.info "#{blue}Delete finished.#{reset}"
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
    ExAws.S3.delete_object!(bucket, asset.key)
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
    [acl: Application.get_env(:cdn, :acl)]

  """
  def s3_options do
    [
      acl: Application.get_env(:cdn, :acl)
    ]
  end
end
