defmodule CuotaProtoWeb.FileUploadController do
  use CuotaProtoWeb, :controller

  alias CuotaProto.FileUploads
  alias CuotaProto.FileUploads.FileUpload

  alias CuotaProto.Repo
  alias CuotaProto.Accounts.User
  alias CuotaProto.Businesses.Matter
  alias CuotaProto.Util.Mailer
  alias CuotaProto.Util.Email

  def index(conn, _params) do
    fileuploads = FileUploads.list_fileuploads()
    render(conn, "index.html", fileuploads: fileuploads)
  end

  def new(conn, _params) do
    changeset = FileUploads.change_file_upload(%FileUpload{})
    email_list = Repo.all(User)
    |> Enum.map(& &1.email)

    IO.puts("**----------")
    IO.inspect(email_list)
    IO.puts("----------**")

    Email.create_email()
    |> Mailer.deliver_now!()
    matter_list = Repo.all(Matter)
    |> Enum.map(& &1.name)
    render(conn, "new.html", changeset: changeset, emails: email_list, matters: matter_list)
  end

  def create(conn, %{"file_upload" => file_upload_params}) do
    IO.inspect(file_upload_params)
    file = file_upload_params["file"]
    IO.inspect(file)
    {_, data} = File.read(file.path)
    IO.inspect(data)
    IO.inspect(file.filename)
    mapdata = %{filedata: data, filename: file.filename}
     case FileUploads.create_file_upload(mapdata) do
      {:ok, file_upload} ->
        conn
         |> put_flash(:info, "File upload created successfully.")
        |> redirect(to: Routes.file_upload_path(conn, :show, file_upload))

       {:error, %Ecto.Changeset{} = changeset} ->
         render(conn, "new.html", changeset: changeset)
     end
    #fileuploads = FileUploads.list_fileuploads()
    #render(conn, "index.html", fileuploads: fileuploads)

  end

  def show(conn, %{"id" => id}) do
    file_upload = FileUploads.get_file_upload!(id)
    render(conn, "show.html", file_upload: file_upload)
  end

  def edit(conn, %{"id" => id}) do
    file_upload = FileUploads.get_file_upload!(id)
    changeset = FileUploads.change_file_upload(file_upload)
    render(conn, "edit.html", file_upload: file_upload, changeset: changeset)
  end

  def update(conn, %{"id" => id, "file_upload" => file_upload_params}) do
    file_upload = FileUploads.get_file_upload!(id)

    case FileUploads.update_file_upload(file_upload, file_upload_params) do
      {:ok, file_upload} ->
        conn
        |> put_flash(:info, "File upload updated successfully.")
        |> redirect(to: Routes.file_upload_path(conn, :show, file_upload))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", file_upload: file_upload, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    file_upload = FileUploads.get_file_upload!(id)
    {:ok, _file_upload} = FileUploads.delete_file_upload(file_upload)

    conn
    |> put_flash(:info, "File upload deleted successfully.")
    |> redirect(to: Routes.file_upload_path(conn, :index))
  end
end
