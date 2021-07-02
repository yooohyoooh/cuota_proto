defmodule CuotaProtoWeb.PageController do
  use CuotaProtoWeb, :controller
  alias CuotaProto.Businesses.Matter

  def index(conn, _params) do
    changeset = Matter.changeset(%Matter{}, %{})
    render(conn, "index.html", changeset: changeset)
  end


end
