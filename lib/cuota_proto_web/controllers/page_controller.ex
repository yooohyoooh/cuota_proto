defmodule CuotaProtoWeb.PageController do
  use CuotaProtoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
