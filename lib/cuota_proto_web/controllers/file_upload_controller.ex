defmodule CuotaProtoWeb.FileUploadController do
  use CuotaProtoWeb, :controller
  import Ecto.Query
  import Plug.Conn

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

  def index_damey(conn) do
    IO.puts("=====delete_conn_session=====")
    IO.inspect(conn)
    IO.puts("=====delete_conn_session=====")
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

  def add_sesion(conn, sessionkey, data) do
    if get_session(conn, sessionkey) do
      mailedata = get_session(conn, sessionkey) ++ data |> Enum.uniq()
      delete_session(conn, sessionkey)
      put_session(conn, sessionkey, mailedata)
    else
      put_session(conn, sessionkey, data)
    end
  end

  def index(conn, _params) do

    # user_email = conn.assigns.current_user.email

    index_damey(delete_session(conn, "email_session"))
  end

  def set(conn, params) do
    IO.puts("=====set_params=====")
    IO.inspect(params)
    IO.puts("=====set_params=====")
    if params != %{} do
      # paramsが空でない＝検索ワードが入っている時に、すでに選択されているアドレスをsessionにput
      new_session = add_sesion(conn, "email_session", params["file_upload"]["email"])
      new_session |> put_flash(:info, "登録できました。") |> redirect(to: Routes.file_upload_path(new_session, :new))

    end
  end

  def delete(conn, params) do
    email_list = get_session(conn, "email_session") -- params["file_upload"]["delete_email"]
    new_session  = put_session(conn, "email_session", email_list)
    new_session |> put_flash(:info, "選択した宛先を選択解除しました。") |> redirect(to: Routes.file_upload_path(new_session, :new))

  end

  def new(conn, params) do
    search_name = params["file_upload"]["search_name"]

    IO.puts("*--------params----------")
    IO.inspect(params)
    IO.puts("----------------------*")

    users = search_email_by_name(search_name)
    changeset = FileUploads.change_file_upload(%FileUpload{})
    matter_list = Repo.all(Matter)
    |> Enum.map(& &1.name)
    render(conn, "new.html", changeset: changeset, emai_users: users, matters: matter_list, email_session: get_session(conn, "email_session"))
  end

  def search_email_by_name(search_name) do
    if search_name do
      search_name_withp = "%" <> search_name <> "%"
      query = from u in "users", where: like(u.email, ^search_name_withp), select: {u.user_name, u.email}
      Repo.all(query)
      |> Enum.map(fn {name, email} -> {"#{name}(#{email})", email} end)

    else
      users_list = Repo.all(User)
      usernames = Enum.map(users_list, & &1.user_name)
      emails = Enum.map(users_list, & &1.email)
      Enum.zip(usernames, emails)
      |> Enum.map(fn {name, email} -> {"#{name}(#{email})", email} end)
    end
  end

  #ファイルをマップにする
  def file_create(file_params) do
    file = file_params
    IO.puts("======get_session.conn=====")
    IO.inspect(file)
    IO.puts("======get_session.conn=====")

    filedata =
    Enum.map(file, & File.read(&1.path))
    |> Enum.map(fn {_state, data} -> data end)

    IO.puts("=======File.data======")
    IO.inspect(filedata)
    IO.puts("=======File.data======")

    filename =
    Enum.map(file, & &1.filename)

    Enum.zip(filedata, filename)
    |>IO.inspect

  end


  def create(conn, _params) do

    IO.puts("====create.conn ========")
    IO.inspect(get_session(conn, "file"))
    IO.puts("====create.conn ========")
    matter= Matter |> Repo.get_by(name: get_session(conn, "matter"))
    |> IO.inspect

    user_id = Enum.map(get_session(conn, "email_session"), &User |> Repo.get_by(email: &1))
    |> Enum.map(& &1.id)
    |> IO.inspect

    file_id = get_session(conn, "file")
    file_data = Enum.map(file_id, & FileUpload |> Repo.get_by(id: &1))


    messagemap =
    %{to_id: user_id, matter_id: [matter.id], file_id: file_id}
    |> IO.inspect

    case Messages.create_message(messagemap) do
      {:ok, _data} -> conn |> put_flash(:info, "登録できました。")
      {:error, _data} -> conn |> put_flash(:info, "登録できませんでした。")
    end

    for email <- get_session(conn, "email_session") do
      mails =
      Email.create_email
      |> Bamboo.Email.to(email)
      mailfiles =
      Enum.reduce(file_data, mails, fn data, acc -> Bamboo.Email.put_attachment(acc, %Bamboo.Attachment{filename: data.filename, data: data.filedata})end)
      |> IO.inspect()
      case Mailer.deliver_now(mailfiles) do
        {:ok, _data} -> conn |> put_flash(:info, "送信されました。") |> redirect(to: Routes.file_upload_path(conn, :index))
        {:error, _data} -> conn |> put_flash(:info, "送信できませんでした。") |> redirect(to: Routes.file_upload_path(conn, :index))
      end
    end

    end

  def preview(conn, %{"file_upload" => file_upload_params}) do
    mapdata =
    file_create(file_upload_params["file"])
    |> Enum.map(fn {data, name} -> %{filedata: data, filename: name} end)

    file_upload_data =
    Enum.map(mapdata, fn data ->
      case FileUploads.create_file_upload(data) do
        {:ok, file_upload} -> file_upload

        {:error, _data} -> :error
      end
    end)

    file_id = Enum.map(file_upload_data, & &1.id)


    new_session
    = conn
    |> put_session("file", file_id)
    |> put_session("matter", file_upload_params["matter"])

    IO.puts("========preview========")
    IO.inspect(new_session)
    IO.puts("========preview========")

    filename =
      Enum.map(file_upload_params["file"], & &1.filename)
      |> IO.inspect()

    render(
      new_session,
      "preview.html",
      from: conn.assigns.current_user.email,
      filename: filename,
      matter: file_upload_params["matter"],
      emails: get_session(new_session, "email_session")
      )
  end
end
