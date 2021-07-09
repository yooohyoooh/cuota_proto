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
  alias CuotaProto.Messages.Message

  def index_damey(conn) do
    IO.puts("=====delete_conn_session=====")
    IO.inspect(conn)
    IO.puts("=====delete_conn_session=====")
    #all_data = Messages.list_messages()
    IO.puts("======my_email======")
    IO.inspect(conn.assigns.current_user)
    IO.puts("======my_email======")
    my_id = Repo.get_by(User, email: conn.assigns.current_user.email)

    IO.puts("======all_my_email======")
    IO.inspect(my_id.id)
    IO.puts("======all_my_email======")

    all_data = Message |> where(user_id: ^my_id.id) |> Repo.all
    IO.puts("-----all_data-----")
    IO.inspect(all_data)
    IO.puts("-----all_data-----")

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
        Enum.map(data.to_id, & Repo.get_by(User, id: &1)) |> Enum.map(& if &1 != nil do "#{&1.user_name}(#{&1.email})" else "ユーザーが存在しません。" end)
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

      datas = Enum.reverse(
      for num <- 1..count do
        %{matter: Enum.at(matter, num - 1), user: Enum.at(user, num - 1), file: Enum.at(file, num - 1), at: Enum.at(at, num - 1)}
      end)
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
    conn
    |> delete_session("email_session")
    |> delete_session("matter")
    |> delete_session("file")
    |> delete_session("body")
    |> delete_session("subject")
    |> index_damey()
  end

  def receive(conn, _params) do
    conn
    |> delete_session("email_session")
    |> delete_session("matter")
    |> delete_session("file")
    |> delete_session("body")
    |> delete_session("subject")
    |> receive_damey()
  end

  def receive_damey(conn) do
    my_id = Repo.get_by(User, email: conn.assigns.current_user.email)

    all_data = Message |> where(to_id: ^[my_id.id]) |> Repo.all

    if all_data != [] do
      matter =
      for data <- all_data do
        Enum.map(data.matter_id, &Businesses.get_matter!(&1)) |> Enum.map(& if &1 != nil do &1.name else "要件がありません。" end)
      end

      user =
      for data <- all_data do
        Enum.map([data.user_id], & Repo.get_by(User, id: &1)) |> Enum.map(& if &1 != nil do "#{&1.user_name}(#{&1.email})" else "ユーザーが存在しません。" end)
      end

      file =
      for data <- all_data do
        Enum.map(data.file_id, &FileUpload |> Repo.get_by(id: &1)) |> Enum.map(& if &1 != nil do &1.filename else "ファイルがありません" end)
      end

      at =
      for data <- all_data do
        data.inserted_at
      end

      count = Enum.count(user)

      datas = Enum.reverse(
      for num <- 1..count do
        %{matter: Enum.at(matter, num - 1), user: Enum.at(user, num - 1), file: Enum.at(file, num - 1), at: Enum.at(at, num - 1)}
      end)
      IO.puts("=====data=====")
      IO.inspect(datas)
      IO.puts("=====data=====")

      render(conn, "receive.html", datas: datas)

    else
      datas = []
      render(conn, "receive.html", datas: datas)
    end

  end


  def set(conn, params) do
    case Map.fetch(params["file_upload"], "email") do
      {:ok, _value} ->
        new_session = add_sesion(conn, "email_session", params["file_upload"]["email"])
        new_session |> put_flash(:info, "登録できました。") |> redirect(to: Routes.file_upload_path(new_session, :new))
      :error -> conn |> put_flash(:info, "選択されていません。") |> redirect(to: Routes.file_upload_path(conn, :new))
    end
  end

  def delete(conn, params) do
    IO.puts("=====delete_params=====")
    IO.inspect(params)
    IO.puts("=====delete_params=====")
    case Map.fetch(params["file_upload"], "delete_email") do
      {:ok, _value} ->
        email_list = get_session(conn, "email_session") -- params["file_upload"]["delete_email"]
        new_session  = put_session(conn, "email_session", email_list)
        new_session |> put_flash(:info, "選択した宛先を選択解除しました。") |> redirect(to: Routes.file_upload_path(new_session, :new))
      :error -> conn |> put_flash(:info, "選択されていません。") |> redirect(to: Routes.file_upload_path(conn, :new))

    end
  end

  def new(conn, params) do
    search_name = params["file_upload"]["search_name"]
    users = search_email_by_name(conn, search_name)

    IO.puts("======users======")
    IO.inspect(users)
    IO.puts("======users======")
    changeset = FileUploads.change_file_upload(%FileUpload{})
    matter_list = Repo.all(Matter)
    |> Enum.map(& &1.name)
    render(conn, "new.html", changeset: changeset, emai_users: users -- [{"#{conn.assigns.current_user.user_name}(#{conn.assigns.current_user.email})", "#{conn.assigns.current_user.email}"}], matters: matter_list, email_session: get_session(conn, "email_session"))
  end

  def cancel_preview(conn, _params) do
    get_session(conn, "file")
    |> Enum.map(& FileUploads.get_file_upload!(&1))
    |> Enum.map(& FileUploads.delete_file_upload(&1))
    redirect(conn, to: Routes.file_upload_path(conn, :new))
  end

  def search_email_by_name(conn, search_name) do
    if search_name do
      search_name_withp = "%" <> search_name <> "%"
      User
      |> where(company_code: ^conn.assigns.current_user.company_code)
      |> where([u],like(u.email, ^search_name_withp))
      |> select([u],{u.user_name, u.email})
      |> Repo.all()
      |> Enum.map(fn {name, email} -> {"#{name}(#{email})", email} end)

    else
      users_list = User |> where(company_code: ^conn.assigns.current_user.company_code) |> Repo.all
      usernames = Enum.map(users_list, & &1.user_name)
      emails = Enum.map(users_list, & &1.email)
      Enum.zip(usernames, emails)
      |> Enum.map(fn {name, email} -> {"#{name}(#{email})", email} end)
    end
  end

  def all(conn, _params) do
    redirect(conn, to: Routes.file_upload_path(conn, :new))
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

    # IO.puts("====create.conn ========")
    # IO.inspect(get_session(conn, "file"))
    # IO.puts("====create.conn ========")
    matter= Matter |> Repo.get_by(name: get_session(conn, "matter"))
    |> IO.inspect

    to_id = Enum.map(get_session(conn, "email_session"), &User |> Repo.get_by(email: &1))
    |> Enum.map(& &1.id)
    |> IO.inspect

    file_id = get_session(conn, "file")
    file_data = Enum.map(file_id, & FileUpload |> Repo.get_by(id: &1))

    user_id = Repo.get_by(User, email: conn.assigns.current_user.email)



    messagemap =
    %{to_id: to_id, matter_id: [matter.id], file_id: file_id, user_id: user_id.id}
    |> IO.inspect

    case Messages.create_message(messagemap) do
      {:ok, _data} -> conn |> put_flash(:info, "登録できました。")
      {:error, _data} -> conn |> put_flash(:info, "登録できませんでした。")
    end

    for email <- get_session(conn, "email_session") do
      mails =
      Email.create_email
      |> Bamboo.Email.to(email)
      |> Bamboo.Email.text_body(get_session(conn, "body"))
      |> Bamboo.Email.from(conn.assigns.current_user.email)
      |> Bamboo.Email.subject(get_session(conn, "subject"))
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
    IO.puts("=======review.conn========")
    IO.inspect(get_session(conn, "email_session"))
    IO.puts("=======review.conn========")
    case get_session(conn, "email_session") do
      nil -> conn |> put_flash(:info, "宛先が選択されていません。") |> redirect(to: Routes.file_upload_path(conn, :new))
      [] -> conn |> put_flash(:info, "宛先が選択されていません。") |> redirect(to: Routes.file_upload_path(conn, :new))
      _ ->
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

      body =
      case file_upload_params["matter"] do
        "共有" ->
          "いつもお世話になっております。\n\r資料を本メールに添付して共有いたします。\n\rお忙しいところ恐れ入りますが、ご確認よろしくお願いいたします。"
        "提出" ->
          "いつもお世話になっております。\n\r資料を本メールに添付して提出いたします。\n\rお忙しいところ恐れ入りますが、ご確認よろしくお願いいたします。"
        "報告" ->
          "いつもお世話になっております。\n\r報告資料を本メールに添付いたします。\n\rお忙しいところ恐れ入りますが、ご確認よろしくお願いいたします。"
        _ ->
          "用件はありません。"
      end

      subject =
      case file_upload_params["matter"] do
        "共有" -> "資料の共有"
        "提出" -> "資料の提出"
        "報告" -> "報告資料の提出"
        _ -> "用件はありません"
      end

      new_session
      = conn
      |> put_session("file", file_id)
      |> put_session("matter", file_upload_params["matter"])
      |> put_session("body", body)
      |> put_session("subject", subject)

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
        emails: get_session(new_session, "email_session"),
        body: get_session(new_session, "body"),
        subject: get_session(new_session, "subject")
        )
    end
  end
end
