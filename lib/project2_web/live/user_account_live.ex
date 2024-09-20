defmodule Project2Web.UserAccountLive do
  use Project2Web, :live_view

  alias Project2.Orders
  alias Project2.Accounts

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    orders = Orders.list_user_orders(user_id)
    pending_orders = Orders.list_pending_orders(user_id)
    address = Accounts.get_user_address(user_id)

    {:ok,
     assign(socket,
       orders: orders,
       pending_orders: pending_orders,
       address: address,
       show_section: nil
     )}
  end

  def handle_event("toggle_section", %{"section" => section}, socket) do
    new_section = if socket.assigns.show_section == section, do: nil, else: section
    {:noreply, assign(socket, show_section: new_section)}
  end

  def render(assigns) do
    ~H"""
    <div class="user-account-container p-8 bg-gray-100">
      <h1 class="text-3xl font-bold text-center text-green-700 mb-8">
        Welcome <%= @address.full_name %>
      </h1>

      <div class="flex flex-col md:flex-row gap-6 mb-12">
        <!-- Completed Orders Icon -->
        <div class="flex-1">
          <button
            phx-click="toggle_section"
            phx-value-section="completed_orders"
            class="flex items-center justify-center p-6 bg-green-600 text-white rounded-lg shadow-lg w-full"
          >
            <i class="fas fa-check-circle fa-2x"></i>
            <span class="ml-2 text-xl">Completed Orders</span>
          </button>
        </div>
        <!-- Pending Orders Icon -->
        <div class="flex-1">
          <button
            phx-click="toggle_section"
            phx-value-section="pending_orders"
            class="flex items-center justify-center p-6 bg-yellow-600 text-white rounded-lg shadow-lg w-full"
          >
            <i class="fas fa-hourglass-half fa-2x"></i>
            <span class="ml-2 text-xl">Pending Orders</span>
          </button>
        </div>
        <!-- Shipping Address Icon -->
        <div class="flex-1">
          <button
            phx-click="toggle_section"
            phx-value-section="shipping_address"
            class="flex items-center justify-center p-6 bg-blue-600 text-white rounded-lg shadow-lg w-full"
          >
            <i class="fas fa-map-marker-alt fa-2x"></i>
            <span class="ml-2 text-xl">Shipping Address</span>
          </button>
        </div>
      </div>
      <!-- Section Content Centered -->
      <div class="flex justify-center mb-12">
        <div class="w-full max-w-3xl">
          <div
            id="completed_orders"
            class={if @show_section == "completed_orders", do: "block", else: "hidden"}
          >
            <%= if @orders == [] do %>
              <p class="text-gray-700 text-lg text-center">You have no completed orders.</p>
            <% else %>
              <ul class="space-y-6">
                <%= for order <- @orders do %>
                  <li class="bg-white p-6 border rounded-lg shadow-lg">
                    <p class="text-xl font-medium mb-2">
                      Amount: <span class="font-semibold text-gray-800"><%= order.amount %></span>
                    </p>
                    <p class="text-lg mb-2">
                      Receipt Number:
                      <span class="font-semibold text-gray-700">
                        <%= order.mpesa_receipt_number %>
                      </span>
                    </p>
                    <p class="text-lg mb-2">Status: <%= order.status %></p>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>

          <div
            id="pending_orders"
            class={if @show_section == "pending_orders", do: "block", else: "hidden"}
          >
            <%= if @pending_orders == [] do %>
              <p class="text-gray-700 text-lg text-center">You have no pending orders.</p>
            <% else %>
              <ul class="space-y-6">
                <%= for pending_order <- @pending_orders do %>
                  <li class="bg-white p-6 border rounded-lg shadow-lg">
                    <p class="text-xl font-medium mb-2">
                      Checkout ID:
                      <span class="font-semibold text-gray-800">
                        <%= pending_order.checkout_id %>
                      </span>
                    </p>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>

          <div
            id="shipping_address"
            class={if @show_section == "shipping_address", do: "block", else: "hidden"}
          >
            <p class="text-xl font-medium mb-2">
              Name: <span class="font-semibold text-gray-800"><%= @address.full_name %></span>
            </p>
            <p class="text-lg mb-2">
              Address:
              <span class="font-semibold text-gray-800">
                <%= @address.shipping_address %>, <%= @address.city %>, <%= @address.state %>, <%= @address.zip_code %>
              </span>
            </p>
            <p class="text-lg mb-2">
              Phone: <span class="font-semibold text-gray-800"><%= @address.phone_number %></span>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
