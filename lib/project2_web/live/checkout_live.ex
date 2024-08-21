defmodule Project2Web.CheckoutLive do
  use Phoenix.LiveView
  alias Project2.Carts

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    case Carts.get_cart(user_id) do
      {:ok, cart} ->
        order_items = Carts.list_order_items(cart.id)
        total_price = calculate_total_price(order_items)

        {:ok,
         assign(socket,
           cart: cart,
           order_items: order_items,
           total_price: total_price,
           shipping_address: "",
           billing_address: "",
           payment_method: "credit_card"
         )}

      {:error, _reason} ->
        {:ok, assign(socket, cart: nil, order_items: [], total_price: 0)}
    end
  end

  def handle_event(
        "update_address",
        %{"shipping_address" => shipping, "billing_address" => billing},
        socket
      ) do
    {:noreply, assign(socket, shipping_address: shipping, billing_address: billing)}
  end

  def handle_event("select_payment_method", %{"payment_method" => payment_method}, socket) do
    {:noreply, assign(socket, payment_method: payment_method)}
  end

  def handle_event("place_order", _params, socket) do
    # Here, you would handle the order placement logic, e.g., saving the order to the database,
    # sending confirmation emails, etc.

    {:noreply, push_navigate(socket, to: "/order-confirmation")}
  end

  defp calculate_total_price(order_items) do
    Enum.reduce(order_items, Decimal.new("0"), fn item, acc ->
      Decimal.add(acc, Decimal.mult(item.product.price, item.quantity))
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="checkout-container p-4">
      <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Checkout</h2>

      <div class="checkout-section">
        <h3 class="font-bold text-lg">Shipping Address</h3>
        <textarea
          phx-change="update_address"
          name="shipping_address"
          class="w-full p-2 mb-4"
          placeholder="Enter your shipping address"
        ></textarea>
      </div>

      <div class="checkout-section">
        <h3 class="font-bold text-lg">Billing Address</h3>
        <textarea
          phx-change="update_address"
          name="billing_address"
          class="w-full p-2 mb-4"
          placeholder="Enter your billing address"
        ></textarea>
      </div>

      <div class="checkout-section">
        <h3 class="font-bold text-lg">Order Summary</h3>
        <ul class="grid grid-cols-1 gap-4 mb-4">
          <%= for item <- @order_items do %>
            <li class="bg-white border rounded shadow p-4 flex items-center">
              <img src={item.product.image_url} alt={item.product.name} class="w-16 h-16 mr-4" />
              <div class="flex-1">
                <h4 class="font-semibold text-md"><%= item.product.name %></h4>
                <p class="text-gray-700">Quantity: <%= item.quantity %></p>
                <p class="text-green-600">Price: <%= item.product.price %></p>
              </div>
            </li>
          <% end %>
        </ul>
        <p class="text-xl font-bold">Total Price: <%= @total_price %></p>
      </div>

      <div class="checkout-section">
        <h3 class="font-bold text-lg">Payment Method</h3>
        <select phx-change="select_payment_method" name="payment_method" class="w-full p-2 mb-4">
          <option value="credit_card" selected>Credit Card</option>
          <option value="paypal">PayPal</option>
          <option value="mpesa">Mpesa</option>
          <option value="bank_transfer">Bank Transfer</option>
        </select>
      </div>

      <div class="checkout-section">
        <button phx-click="place_order" class="bg-green-500 text-white p-2 rounded w-full">
          Place Order
        </button>
      </div>
    </div>
    """
  end
end
