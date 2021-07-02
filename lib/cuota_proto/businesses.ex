defmodule CuotaProto.Businesses do
  @moduledoc """
  The Businesses context.
  """

  import Ecto.Query, warn: false
  alias CuotaProto.Repo

  alias CuotaProto.Businesses.Matter

  @doc """
  Returns the list of matters.

  ## Examples

      iex> list_matters()
      [%Matter{}, ...]

  """
  def list_matters do
    Repo.all(Matter)
  end

  @doc """
  Gets a single matter.

  Raises `Ecto.NoResultsError` if the Matter does not exist.

  ## Examples

      iex> get_matter!(123)
      %Matter{}

      iex> get_matter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_matter!(id), do: Repo.get!(Matter, id)

  @doc """
  Creates a matter.

  ## Examples

      iex> create_matter(%{field: value})
      {:ok, %Matter{}}

      iex> create_matter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_matter(attrs \\ %{}) do
    %Matter{}
    |> Matter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a matter.

  ## Examples

      iex> update_matter(matter, %{field: new_value})
      {:ok, %Matter{}}

      iex> update_matter(matter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_matter(%Matter{} = matter, attrs) do
    matter
    |> Matter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a matter.

  ## Examples

      iex> delete_matter(matter)
      {:ok, %Matter{}}

      iex> delete_matter(matter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_matter(%Matter{} = matter) do
    Repo.delete(matter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking matter changes.

  ## Examples

      iex> change_matter(matter)
      %Ecto.Changeset{data: %Matter{}}

  """
  def change_matter(%Matter{} = matter, attrs \\ %{}) do
    Matter.changeset(matter, attrs)
  end
end
