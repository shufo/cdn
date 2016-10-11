defmodule Mix.Tasks.Cdn.Empty do
  use Mix.Task

  @shortdoc "Delete Assets in CDN"

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:ex_aws)
    {:ok, _} = Application.ensure_all_started(:httpoison)

    bucket = Application.get_env(:cdn, :bucket)

    Cdn.S3.delete_objects(bucket)
  end
end
