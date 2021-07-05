defmodule CuotaProtoWeb.FileUploadController do
  use CuotaProtoWeb, :controller

  alias CuotaProto.FileUploads
  alias CuotaProto.FileUploads.FileUpload

  alias CuotaProto.Repo
  alias CuotaProto.Accounts.User
  alias CuotaProto.Businesses.Matter
  alias CuotaProto.Util.Mailer
  alias CuotaProto.Util.Email

  alias CuotaProto.Messages

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

    # Email.create_email()
    # |> Mailer.deliver_now!()
    matter_list = Repo.all(Matter)
    |> Enum.map(& &1.name)
    render(conn, "new.html", changeset: changeset, emails: email_list, matters: matter_list)
  end

  def create(conn, %{"file_upload" => file_upload_params}) do
    IO.inspect(file_upload_params)

    file = file_upload_params["file"]
    IO.inspect(file)

    filedata =
    Enum.map(file, & File.read(&1.path))
    |> Enum.map(fn {state, data} -> data end)
    |> IO.inspect()

    filename =
    Enum.map(file, & &1.filename)
    |> IO.inspect()

    mapdata =
    Enum.zip(filedata, filename)
    |> Enum.map(fn {data, name} -> %{filedata: data, filename: name} end)
    |> IO.inspect()


    matter= Matter |> Repo.get_by(name: file_upload_params["matter"])
    |> IO.inspect

    user = User |> Repo.get_by(email: file_upload_params["email"])
    |> IO.inspect

    Enum.map(mapdata, fn data ->
      case FileUploads.create_file_upload(data) do
        {:ok, file_upload} ->
          conn
          |> put_flash(:info, "File upload created successfully.")
          #|> redirect(to: Routes.file_upload_path(conn, :show, file_upload))

        {:error, %Ecto.Changeset{} = changeset} ->
          #render(conn, "new.html", changeset: changeset)
          :error
      end
    end)

    file_id = Enum.map(filename, & FileUpload |> Repo.get_by(filename: &1))
    |> Enum.map(& &1.id)
    |> IO.inspect

    messagemap =
    %{to_id: user.id, matter_id: matter.id, file_id: file_id}
    |> IO.inspect
    |> Messages.create_message()
    |> IO.inspect

    IO.puts("成功")

    fileuploads = FileUploads.list_fileuploads()
    render(conn, "index.html", fileuploads: fileuploads)

  end

  def show(conn, %{"id" => id}) do
    file_upload = FileUploads.get_file_upload!(id)
    render(conn, "show.html", file_upload: file_upload)
  end

  def edit(conn, %{"id" => id}) do
    IO.inspect(id)
    file_upload = FileUploads.get_file_upload!(id)
    |> IO.inspect
    #changeset = FileUploads.change_file_upload(file_upload)
    render(conn, "edit.html", file_upload: file_upload)
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
