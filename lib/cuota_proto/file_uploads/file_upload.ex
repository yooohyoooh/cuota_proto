defmodule CuotaProto.FileUploads.FileUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "fileuploads" do
    field :filedata, :binary
    field :filename, :string

    timestamps()
  end

  @doc false
  def changeset(file_upload, attrs) do
    file_upload
    |> cast(attrs, [:filename, :filedata])
    |> validate_required([:filename, :filedata])
  end
end
