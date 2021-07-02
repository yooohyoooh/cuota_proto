defmodule CuotaProto.FileUploads do
  @moduledoc """
  The FileUploads context.
  """

  import Ecto.Query, warn: false
  alias CuotaProto.Repo

  alias CuotaProto.FileUploads.FileUpload

  @doc """
  Returns the list of fileuploads.

  ## Examples

      iex> list_fileuploads()
      [%FileUpload{}, ...]

  """
  def list_fileuploads do
    Repo.all(FileUpload)
  end

  @doc """
  Gets a single file_upload.

  Raises `Ecto.NoResultsError` if the File upload does not exist.

  ## Examples

      iex> get_file_upload!(123)
      %FileUpload{}

      iex> get_file_upload!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file_upload!(id), do: Repo.get!(FileUpload, id)

  @doc """
  Creates a file_upload.

  ## Examples

      iex> create_file_upload(%{field: value})
      {:ok, %FileUpload{}}

      iex> create_file_upload(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file_upload(attrs \\ %{}) do
    %FileUpload{}
    |> FileUpload.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file_upload.

  ## Examples

      iex> update_file_upload(file_upload, %{field: new_value})
      {:ok, %FileUpload{}}

      iex> update_file_upload(file_upload, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file_upload(%FileUpload{} = file_upload, attrs) do
    file_upload
    |> FileUpload.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file_upload.

  ## Examples

      iex> delete_file_upload(file_upload)
      {:ok, %FileUpload{}}

      iex> delete_file_upload(file_upload)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file_upload(%FileUpload{} = file_upload) do
    Repo.delete(file_upload)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file_upload changes.

  ## Examples

      iex> change_file_upload(file_upload)
      %Ecto.Changeset{data: %FileUpload{}}

  """
  def change_file_upload(%FileUpload{} = file_upload, attrs \\ %{}) do
    FileUpload.changeset(file_upload, attrs)
  end
end
