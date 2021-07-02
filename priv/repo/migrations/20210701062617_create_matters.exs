defmodule CuotaProto.Repo.Migrations.CreateMatters do
  use Ecto.Migration

  def change do
    create table(:matters) do
      add :name, :string

      timestamps()
    end

  end
end
