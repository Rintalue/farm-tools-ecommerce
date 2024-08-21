defmodule Project2Web.VendorAccountLive do
  use Phoenix.LiveView
  alias Project2.Carts

  def mount(_params, _session, socket) do
    vendor_id = socket.assigns.current_vendor.id
    orders = Carts.list_orders_by_vendor(vendor_id)

    {:ok, assign(socket, orders: orders)}
  end

  def handle_event("approve_order", %{"order_id" => order_id}, socket) do
    Carts.update_order_status(order_id, "approved")
    {:noreply, update_orders(socket)}
  end

  def handle_event("decline_order", %{"order_id" => order_id}, socket) do
    Carts.update_order_status(order_id, "declined")
    {:noreply, update_orders(socket)}
  end

  defp update_orders(socket) do
    vendor_id = socket.assigns.current_vendor.id
    orders = Carts.list_orders_by_vendor(vendor_id)
    assign(socket, orders: orders)
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Manage Orders</h2>
      <%= if @orders == [] do %>
        <p>No orders to manage.</p>
      <% else %>
        <ul class="list-none">
          <%= for order <- @orders do %>
            <li class="p-4 mb-4 border-b">
              <p>Product: <%= order.product.name %></p>
              <p>Quantity: <%= order.quantity %></p>
              <p>Status: <%= order.status %></p>
              <%= if order.status == "pending" do %>
                <button
                  phx-click="approve_order"
                  phx-value-order_id={order.id}
                  class="bg-green-500 text-white p-2 rounded"
                >
                  Approve
                </button>
                <button
                  phx-click="decline_order"
                  phx-value-order_id={order.id}
                  class="bg-red-500 text-white p-2 rounded"
                >
                  Decline
                </button>
              <% end %>
            </li>
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end
end
