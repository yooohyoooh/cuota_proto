defmodule CuotaProtoWeb.PageController do
  use CuotaProtoWeb, :controller

  alias CuotaProto.Businesses.Matter
  alias CuotaProto.Accounts.User
  alias CuotaProto.Repo

  def index(conn, _params) do
    changeset = Matter.changeset(%Matter{}, %{})
    render(conn, "index.html", changeset: changeset)
  end

  def to(conn, params) do
    IO.inspect(params)
    users = Repo.all(User)
    # email = Enum.map(users, & &1.email)
    render(conn, "to.html", users: users)
  end

  def path(conn, params) do
    IO.inspect(params)
    render(conn, "path.html", params: params)
  end

  def delete(conn, _)do
    {state, _} = CuotaProto.FileUploads.FileUpload |> CuotaProto.Repo.delete_all()
    |> IO.inspect
    case state do
      0 -> conn |> put_flash(:info, "削除するファイルがありませんでした。") |> redirect(to: Routes.file_upload_path(conn, :index))
      _ -> conn |> put_flash(:info, "ファイルを全部削除しました。") |> redirect(to: Routes.file_upload_path(conn, :index))
    end
  end

  def all_delete(conn, _) do
    {state, _} = CuotaProto.Messages.Message |> CuotaProto.Repo.delete_all()
    |> IO.inspect

    case state do
      0 -> conn |> put_flash(:info, "削除するデータがありませんでした。") |> redirect(to: Routes.file_upload_path(conn, :index))
      _ -> conn |> put_flash(:info, "全件削除しました。") |> redirect(to: Routes.file_upload_path(conn, :index))
    end
  end
end
