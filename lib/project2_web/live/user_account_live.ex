# lib/project2_web/live/user_account_live.ex
defmodule Project2Web.UserAccountLive do
  use Phoenix.LiveView
  alias Project2.Carts

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    orders = Carts.list_orders_by_user(user_id)

    {:ok, assign(socket, orders: orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h2 class="text-center font-bold text-2xl text-green-700 mb-4">My Orders</h2>
      <%= if @orders == [] do %>
        <p>You have no orders yet.</p>
      <% else %>
        <ul class="list-none">
          <%= for order <- @orders do %>
            <li class="p-4 mb-4 border-b">
              <p>Product: <%= order.product.name %></p>
              <p>Quantity: <%= order.quantity %></p>
              <p>Status: <%= order.status %></p>
            </li>
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end
end
