defmodule CuotaProto.Repo.Migrations.AddComponyCode do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :company_code, :string
    end

    alter table(:messages) do
      add :user_id, :integer
    end
  end
end
