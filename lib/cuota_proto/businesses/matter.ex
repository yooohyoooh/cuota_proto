defmodule CuotaProto.Businesses.Matter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matters" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(matter, attrs) do
    matter
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
