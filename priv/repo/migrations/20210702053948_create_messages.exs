defmodule CuotaProto.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :to_id, {:array, :integer}
      add :matter_id, {:array, :integer}
      add :file_id, {:array, :integer}

      timestamps()
    end

  end
end
