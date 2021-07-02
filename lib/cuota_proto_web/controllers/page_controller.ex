defmodule CuotaProtoWeb.PageController do
  use CuotaProtoWeb, :controller
  alias CuotaProto.Accounts.User
  alias CuotaProto.Repo

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def to(conn, params) do
    IO.inspect(params)
    users = Repo.all(User)
    names = Enum.map(users, & &1.name)
    render(conn, "to.html", names: names)
  end

  def path(conn, params) do
    IO.inspect(params)
    render(conn, "path.html", params: params)
  end
end
