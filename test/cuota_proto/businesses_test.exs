defmodule CuotaProto.BusinessesTest do
  use CuotaProto.DataCase

  alias CuotaProto.Businesses

  describe "matters" do
    alias CuotaProto.Businesses.Matter

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def matter_fixture(attrs \\ %{}) do
      {:ok, matter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Businesses.create_matter()

      matter
    end

    test "list_matters/0 returns all matters" do
      matter = matter_fixture()
      assert Businesses.list_matters() == [matter]
    end

    test "get_matter!/1 returns the matter with given id" do
      matter = matter_fixture()
      assert Businesses.get_matter!(matter.id) == matter
    end

    test "create_matter/1 with valid data creates a matter" do
      assert {:ok, %Matter{} = matter} = Businesses.create_matter(@valid_attrs)
      assert matter.name == "some name"
    end

    test "create_matter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Businesses.create_matter(@invalid_attrs)
    end

    test "update_matter/2 with valid data updates the matter" do
      matter = matter_fixture()
      assert {:ok, %Matter{} = matter} = Businesses.update_matter(matter, @update_attrs)
      assert matter.name == "some updated name"
    end

    test "update_matter/2 with invalid data returns error changeset" do
      matter = matter_fixture()
      assert {:error, %Ecto.Changeset{}} = Businesses.update_matter(matter, @invalid_attrs)
      assert matter == Businesses.get_matter!(matter.id)
    end

    test "delete_matter/1 deletes the matter" do
      matter = matter_fixture()
      assert {:ok, %Matter{}} = Businesses.delete_matter(matter)
      assert_raise Ecto.NoResultsError, fn -> Businesses.get_matter!(matter.id) end
    end

    test "change_matter/1 returns a matter changeset" do
      matter = matter_fixture()
      assert %Ecto.Changeset{} = Businesses.change_matter(matter)
    end
  end
end
