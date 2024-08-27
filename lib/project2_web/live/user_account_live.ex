defmodule Project2Web.UserAccountLive do
  use Phoenix.LiveView
  alias Project2.Carts.Cart

  def render(assigns) do
    ~H"""
    <div>
      <h1>My Orders</h1>
      <ul>
        <%= for item <- @order_items do %>
          <li>
            <%= item.product.name %> - <%= item.status %>
            <%= if item.status == "paid" do %>
              <p>Receipt Number: <%= item.mpesa_receipt_number %></p>
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, session, socket) do
    user = Project2.Accounts.get_user!(session["user_id"])
    order_items = Cart.get_user_order_items(user.id)

    {:ok, assign(socket, order_items: order_items)}
  end
end
