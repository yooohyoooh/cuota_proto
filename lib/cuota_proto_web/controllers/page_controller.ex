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
    email = Enum.map(users, & &1.email)
    render(conn, "to.html", names: email)
  end

  def path(conn, params) do
    IO.inspect(params)
    render(conn, "path.html", params: params)
  end
end
