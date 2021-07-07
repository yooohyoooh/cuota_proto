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

    user_email = conn.assigns.current_user.email
    IO.puts("=====user_email=====")
    IO.inspect(user_email)
    IO.puts("=====user_email=====")

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
    email_list = get_session(conn, "email_session") -- [params["file_upload"]["delete_email"]]
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



  def create(conn, %{"file_upload" => file_upload_params}) do
    #IO.inspect(file_upload_params)
    new_session = add_sesion(conn, "email_session", file_upload_params["email"])

    file = file_upload_params["file"]
    IO.inspect(file)



    filedata =
    Enum.map(file, & File.read(&1.path))
    |> Enum.map(fn {_state, data} -> data end)
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

    user_id = Enum.map(get_session(new_session, "email_session"), &User |> Repo.get_by(email: &1))
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
    # このタイミングでsessionに入っているemail_sessionを持ってきたいが、putしたはずなのに入っていない
    IO.puts("========get_session==========")
    IO.inspect(conn)
    IO.puts("=========================")

    IO.puts("=====get_email_session=====")
    IO.inspect(get_session(conn, "email_session"))
    IO.puts("=====get_email_session=====")
    for email <- get_session(new_session, "email_session") do
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

    index_damey(new_session)
  end
end
