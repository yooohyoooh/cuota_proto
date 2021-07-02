defmodule CuotaProto.FileUploadsTest do
  use CuotaProto.DataCase

  alias CuotaProto.FileUploads

  describe "fileuploads" do
    alias CuotaProto.FileUploads.FileUpload

    @valid_attrs %{filedata: "some filedata", filename: "some filename"}
    @update_attrs %{filedata: "some updated filedata", filename: "some updated filename"}
    @invalid_attrs %{filedata: nil, filename: nil}

    def file_upload_fixture(attrs \\ %{}) do
      {:ok, file_upload} =
        attrs
        |> Enum.into(@valid_attrs)
        |> FileUploads.create_file_upload()

      file_upload
    end

    test "list_fileuploads/0 returns all fileuploads" do
      file_upload = file_upload_fixture()
      assert FileUploads.list_fileuploads() == [file_upload]
    end

    test "get_file_upload!/1 returns the file_upload with given id" do
      file_upload = file_upload_fixture()
      assert FileUploads.get_file_upload!(file_upload.id) == file_upload
    end

    test "create_file_upload/1 with valid data creates a file_upload" do
      assert {:ok, %FileUpload{} = file_upload} = FileUploads.create_file_upload(@valid_attrs)
      assert file_upload.filedata == "some filedata"
      assert file_upload.filename == "some filename"
    end

    test "create_file_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FileUploads.create_file_upload(@invalid_attrs)
    end

    test "update_file_upload/2 with valid data updates the file_upload" do
      file_upload = file_upload_fixture()
      assert {:ok, %FileUpload{} = file_upload} = FileUploads.update_file_upload(file_upload, @update_attrs)
      assert file_upload.filedata == "some updated filedata"
      assert file_upload.filename == "some updated filename"
    end

    test "update_file_upload/2 with invalid data returns error changeset" do
      file_upload = file_upload_fixture()
      assert {:error, %Ecto.Changeset{}} = FileUploads.update_file_upload(file_upload, @invalid_attrs)
      assert file_upload == FileUploads.get_file_upload!(file_upload.id)
    end

    test "delete_file_upload/1 deletes the file_upload" do
      file_upload = file_upload_fixture()
      assert {:ok, %FileUpload{}} = FileUploads.delete_file_upload(file_upload)
      assert_raise Ecto.NoResultsError, fn -> FileUploads.get_file_upload!(file_upload.id) end
    end

    test "change_file_upload/1 returns a file_upload changeset" do
      file_upload = file_upload_fixture()
      assert %Ecto.Changeset{} = FileUploads.change_file_upload(file_upload)
    end
  end
end
