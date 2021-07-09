defmodule CuotaProto.Repo.Migrations.AddToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_name, :string
      add :company_code, :string
    end
  end
end
