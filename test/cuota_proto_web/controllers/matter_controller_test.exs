defmodule CuotaProtoWeb.MatterControllerTest do
  use CuotaProtoWeb.ConnCase

  alias CuotaProto.Businesses

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:matter) do
    {:ok, matter} = Businesses.create_matter(@create_attrs)
    matter
  end

  describe "index" do
    test "lists all matters", %{conn: conn} do
      conn = get(conn, Routes.matter_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Matters"
    end
  end

  describe "new matter" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.matter_path(conn, :new))
      assert html_response(conn, 200) =~ "New Matter"
    end
  end

  describe "create matter" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.matter_path(conn, :create), matter: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.matter_path(conn, :show, id)

      conn = get(conn, Routes.matter_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Matter"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.matter_path(conn, :create), matter: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Matter"
    end
  end

  describe "edit matter" do
    setup [:create_matter]

    test "renders form for editing chosen matter", %{conn: conn, matter: matter} do
      conn = get(conn, Routes.matter_path(conn, :edit, matter))
      assert html_response(conn, 200) =~ "Edit Matter"
    end
  end

  describe "update matter" do
    setup [:create_matter]

    test "redirects when data is valid", %{conn: conn, matter: matter} do
      conn = put(conn, Routes.matter_path(conn, :update, matter), matter: @update_attrs)
      assert redirected_to(conn) == Routes.matter_path(conn, :show, matter)

      conn = get(conn, Routes.matter_path(conn, :show, matter))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, matter: matter} do
      conn = put(conn, Routes.matter_path(conn, :update, matter), matter: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Matter"
    end
  end

  describe "delete matter" do
    setup [:create_matter]

    test "deletes chosen matter", %{conn: conn, matter: matter} do
      conn = delete(conn, Routes.matter_path(conn, :delete, matter))
      assert redirected_to(conn) == Routes.matter_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.matter_path(conn, :show, matter))
      end
    end
  end

  defp create_matter(_) do
    matter = fixture(:matter)
    %{matter: matter}
  end
end
