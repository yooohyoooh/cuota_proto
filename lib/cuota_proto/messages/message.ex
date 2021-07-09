defmodule CuotaProto.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :file_id, {:array, :integer}
    field :matter_id, {:array, :integer}
    field :to_id, {:array, :integer}
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:to_id, :matter_id, :file_id, :user_id])
    |> validate_required([:to_id, :matter_id, :file_id, :user_id])
  end
end
