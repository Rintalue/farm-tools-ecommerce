defmodule Project2Web.VendorAccountLive do
  use Phoenix.LiveView
  alias Project2.Products

  def render(assigns) do
    ~H"""
    <div>
      <h1>My Sales</h1>
      <ul>
        <%= for {product, items} <- @sales do %>
          <li>
            <%= product.name %>:
            Total Sold: <%= Enum.count(items) %> Total Earned: KES <%= Enum.sum(
              Enum.map(items, & &1.amount_paid)
            ) %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, session, socket) do
    vendor = Project2.Vendors.get_vendor!(session["vendor_id"])
    sales = Products.get_vendor_sales(vendor.id)

    {:ok, assign(socket, sales: sales)}
  end
end
