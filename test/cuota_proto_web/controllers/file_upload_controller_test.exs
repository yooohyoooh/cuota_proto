defmodule CuotaProtoWeb.FileUploadControllerTest do
  use CuotaProtoWeb.ConnCase

  alias CuotaProto.FileUploads

  @create_attrs %{filedata: "some filedata", filename: "some filename"}
  @update_attrs %{filedata: "some updated filedata", filename: "some updated filename"}
  @invalid_attrs %{filedata: nil, filename: nil}

  def fixture(:file_upload) do
    {:ok, file_upload} = FileUploads.create_file_upload(@create_attrs)
    file_upload
  end

  describe "index" do
    test "lists all fileuploads", %{conn: conn} do
      conn = get(conn, Routes.file_upload_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Fileuploads"
    end
  end

  describe "new file_upload" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.file_upload_path(conn, :new))
      assert html_response(conn, 200) =~ "New File upload"
    end
  end

  describe "create file_upload" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.file_upload_path(conn, :create), file_upload: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.file_upload_path(conn, :show, id)

      conn = get(conn, Routes.file_upload_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show File upload"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.file_upload_path(conn, :create), file_upload: @invalid_attrs)
      assert html_response(conn, 200) =~ "New File upload"
    end
  end

  describe "edit file_upload" do
    setup [:create_file_upload]

    test "renders form for editing chosen file_upload", %{conn: conn, file_upload: file_upload} do
      conn = get(conn, Routes.file_upload_path(conn, :edit, file_upload))
      assert html_response(conn, 200) =~ "Edit File upload"
    end
  end

  describe "update file_upload" do
    setup [:create_file_upload]

    test "redirects when data is valid", %{conn: conn, file_upload: file_upload} do
      conn = put(conn, Routes.file_upload_path(conn, :update, file_upload), file_upload: @update_attrs)
      assert redirected_to(conn) == Routes.file_upload_path(conn, :show, file_upload)

      conn = get(conn, Routes.file_upload_path(conn, :show, file_upload))
      assert html_response(conn, 200) =~ "some updated filename"
    end

    test "renders errors when data is invalid", %{conn: conn, file_upload: file_upload} do
      conn = put(conn, Routes.file_upload_path(conn, :update, file_upload), file_upload: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit File upload"
    end
  end

  describe "delete file_upload" do
    setup [:create_file_upload]

    test "deletes chosen file_upload", %{conn: conn, file_upload: file_upload} do
      conn = delete(conn, Routes.file_upload_path(conn, :delete, file_upload))
      assert redirected_to(conn) == Routes.file_upload_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.file_upload_path(conn, :show, file_upload))
      end
    end
  end

  defp create_file_upload(_) do
    file_upload = fixture(:file_upload)
    %{file_upload: file_upload}
  end
end
