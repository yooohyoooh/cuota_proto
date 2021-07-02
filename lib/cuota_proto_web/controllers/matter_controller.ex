defmodule CuotaProtoWeb.MatterController do
  use CuotaProtoWeb, :controller

  alias CuotaProto.Businesses
  alias CuotaProto.Businesses.Matter

  def index(conn, _params) do
    matters = Businesses.list_matters()
    render(conn, "index.html", matters: matters)
  end

  def new(conn, _params) do
    changeset = Businesses.change_matter(%Matter{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"matter" => matter_params}) do
    case Businesses.create_matter(matter_params) do
      {:ok, matter} ->
        conn
        |> put_flash(:info, "Matter created successfully.")
        |> redirect(to: Routes.matter_path(conn, :show, matter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    matter = Businesses.get_matter!(id)
    render(conn, "show.html", matter: matter)
  end

  def edit(conn, %{"id" => id}) do
    matter = Businesses.get_matter!(id)
    changeset = Businesses.change_matter(matter)
    render(conn, "edit.html", matter: matter, changeset: changeset)
  end

  def update(conn, %{"id" => id, "matter" => matter_params}) do
    matter = Businesses.get_matter!(id)

    case Businesses.update_matter(matter, matter_params) do
      {:ok, matter} ->
        conn
        |> put_flash(:info, "Matter updated successfully.")
        |> redirect(to: Routes.matter_path(conn, :show, matter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", matter: matter, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    matter = Businesses.get_matter!(id)
    {:ok, _matter} = Businesses.delete_matter(matter)

    conn
    |> put_flash(:info, "Matter deleted successfully.")
    |> redirect(to: Routes.matter_path(conn, :index))
  end


end
