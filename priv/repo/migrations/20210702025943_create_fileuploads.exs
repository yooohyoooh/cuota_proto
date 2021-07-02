defmodule CuotaProto.Repo.Migrations.CreateFileuploads do
  use Ecto.Migration

  def change do
    create table(:fileuploads) do
      add :filename, :string
      add :filedata, :binary

      timestamps()
    end

  end
end
