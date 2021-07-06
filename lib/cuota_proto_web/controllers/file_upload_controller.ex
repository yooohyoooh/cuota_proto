defmodule CuotaProtoWeb.FileUploadController do
  use CuotaProtoWeb, :controller

  alias CuotaProto.FileUploads
  alias CuotaProto.FileUploads.FileUpload

  alias CuotaProto.Repo

  alias CuotaProto.Accounts.User
  alias CuotaProto.Accounts

  alias CuotaProto.Businesses.Matter
  alias CuotaProto.Businesses

  alias CuotaProto.Util.Mailer
  alias CuotaProto.Util.Email

  alias CuotaProto.Messages

  def index(conn, _params) do
    all_data = Messages.list_messages()
    |> IO.inspect

    if all_data != [] do
      matter =
      for data <- all_data do
        Enum.map(data.matter_id, &Businesses.get_matter!(&1)) |> Enum.map(& if &1 != nil do &1.name else "要件がありません。" end)
      end

      IO.puts("-----matter-----")
      IO.inspect(matter)
      IO.puts("-----matter-----")

      user =
      for data <- all_data do
        Enum.map(data.to_id, &Accounts.get_user!(&1)) |> Enum.map(& if &1 != nil do "#{&1.user_name}(#{&1.email})" else "ユーザーが存在しません。" end)
      end

      IO.puts("-----user-----")
      IO.inspect(user)
      IO.puts("-----user-----")

      file =
      for data <- all_data do
        Enum.map(data.file_id, &FileUpload |> Repo.get_by(id: &1)) |> Enum.map(& if &1 != nil do &1.filename else "ファイルがありません" end)
      end

      IO.puts("-----file-----")
      IO.inspect(file)
      IO.puts("-----file-----")

      at =
      for data <- all_data do
        data.inserted_at
      end

      IO.puts("-----at-----")
      IO.inspect(at)
      IO.puts("-----at-----")

      count = Enum.count(user)

      datas =
      for num <- 1..count do
        %{matter: Enum.at(matter, num - 1), user: Enum.at(user, num - 1), file: Enum.at(file, num - 1), at: Enum.at(at, num - 1)}
      end
      IO.puts("=====data=====")
      IO.inspect(datas)
      IO.puts("=====data=====")

      render(conn, "index.html", datas: datas)

    else
      datas = []
      render(conn, "index.html", datas: datas)
    end
  end

  def new(conn, _params) do
    changeset = FileUploads.change_file_upload(%FileUpload{})
    users_list = Repo.all(User)
    usernames = Enum.map(users_list, & &1.user_name)
    emails = Enum.map(users_list, & &1.email)
    users =
    Enum.zip(usernames, emails)
    |> IO.inspect
    |> Enum.map(fn {name, email} -> {"#{name}(#{email})", email} end)

    IO.puts("**----------")
    IO.inspect(usernames)
    IO.inspect(emails)
    IO.inspect(users)
    IO.puts("----------**")

    matter_list = Repo.all(Matter)
    |> Enum.map(& &1.name)
    render(conn, "new.html", changeset: changeset, emai_users: users, matters: matter_list)
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

    data = Enum.zip(filedata, filename)

    mapdata =
    data
    |> Enum.map(fn {data, name} -> %{filedata: data, filename: name} end)
    |> IO.inspect()


    matter= Matter |> Repo.get_by(name: file_upload_params["matter"])
    |> IO.inspect

    user_id = Enum.map(file_upload_params["email"], &User |> Repo.get_by(email: &1))
    |> Enum.map(& &1.id)
    |> IO.inspect

    file_upload_data =
    Enum.map(mapdata, fn data ->
      case FileUploads.create_file_upload(data) do
        {:ok, file_upload} ->
          conn
          |> put_flash(:info, "File upload created successfully.")
          file_upload
          #|> redirect(to: Routes.file_upload_path(conn, :show, file_upload))

        {:error, _data} ->
          #render(conn, "new.html", changeset: changeset)
          :error
      end
    end)
    IO.inspect(file_upload_data)

    # file_id = Enum.map(filename, & FileUpload |> Repo.get_by(filename: &1))
    # |> Enum.map(& &1.id)
    # |> IO.inspect
    file_id = Enum.map(file_upload_data, & &1.id)


    IO.puts("========file_id==========")
    IO.inspect(file_id)
    IO.puts("=========================")

    messagemap =
    %{to_id: user_id, matter_id: [matter.id], file_id: file_id}
    |> IO.inspect

    case Messages.create_message(messagemap) do
      {:ok, _data} -> conn |> put_flash(:info, "登録できました。")
      {:error, _data} -> conn |> put_flash(:info, "登録できませんでした。")
    end
    #IO.puts("成功")

    for email <- file_upload_params["email"] do
      mails =
      Email.create_email
      |> Bamboo.Email.to(email)
      mailfiles =
      Enum.reduce(data, mails, fn {filedata, filename}, acc -> Bamboo.Email.put_attachment(acc, %Bamboo.Attachment{filename: filename, data: filedata})end)
      |> IO.inspect()
      case Mailer.deliver_now(mailfiles) do
        {:ok, _data} -> conn |> put_flash(:info, "送信できました。")
        {:error, _data} -> conn |> put_flash(:info, "送信できませんでした。")
      end
    end

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

  def delete(conn, %{"id" => id} = params)do
    IO.inspect(id)
    IO.inspect(params)
    file_upload = FileUploads.get_file_upload!(id)
    {:ok, _file_upload} = FileUploads.delete_file_upload(file_upload)

    conn
    |> put_flash(:info, "File upload deleted successfully.")
    |> redirect(to: Routes.file_upload_path(conn, :index))
  end
end
