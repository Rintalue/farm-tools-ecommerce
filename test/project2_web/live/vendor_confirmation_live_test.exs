defmodule Project2Web.VendorConfirmationLiveTest do
  use Project2Web.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Project2.VendorsFixtures

  alias Project2.Vendors
  alias Project2.Repo

  setup do
    %{vendor: vendor_fixture()}
  end

  describe "Confirm vendor" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/vendors/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, vendor: vendor} do
      token =
        extract_vendor_token(fn url ->
          Vendors.deliver_vendor_confirmation_instructions(vendor, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/vendors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Vendor confirmed successfully"

      assert Vendors.get_vendor!(vendor.id).confirmed_at
      refute get_session(conn, :vendor_token)
      assert Repo.all(Vendors.VendorToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/vendors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Vendor confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_vendor(vendor)

      {:ok, lv, _html} = live(conn, ~p"/vendors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, vendor: vendor} do
      {:ok, lv, _html} = live(conn, ~p"/vendors/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Vendor confirmation link is invalid or it has expired"

      refute Vendors.get_vendor!(vendor.id).confirmed_at
    end
  end
end
