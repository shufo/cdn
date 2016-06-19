defmodule Mix.Tasks.Cdn.Push do
  use Mix.Task
  require Logger
  import Cdn.File
  import Cdn.S3
  import Cdn.Utils

  @shortdoc "Push Assets to CDN"

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:ex_aws)
    {:ok, _} = Application.ensure_all_started(:httpoison)

    bucket = Application.get_env(:cdn, :bucket)

    files_on_aws = list_files_already_on_bucket(bucket)

    upload_to_cdn(bucket, list_files_in_local, files_on_aws)
  end

  def upload_to_cdn(bucket, assets, files_on_aws) do
    assets
    |> Enum.filter(&(should_upload?(&1, files_on_aws)))
    |> put_objects(bucket)
  end

  def should_upload?({_, asset} = _target, files_on_aws) do
    case already_exists?(asset.path, files_on_aws) do
      true ->
        file_on_aws = files_on_aws[:"#{asset.path}"]
        # select to upload files that are different in last modified time and size
        asset.mtime != iso_z_to_secs(file_on_aws.last_modified)
                and asset.size != file_on_aws.size |> String.to_integer
      false -> true
    end
  end

  def already_exists?(asset_path, files_on_aws) do
    Keyword.has_key?(files_on_aws, asset_path |> String.to_atom)
  end
end
