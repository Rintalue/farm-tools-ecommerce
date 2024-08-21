defmodule Project2Web.CartLive do
  use Phoenix.LiveView
  alias Project2.Carts

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id |> IO.inspect()
    IO.inspect(user_id, label: "User ID in CartLive mount")

    if user_id do
      cart =
        case Carts.get_cart(user_id) do
          {:ok, cart} -> cart
          {:error, _} -> {:ok, _cart} = Carts.create_cart(user_id)
        end

      order_items = Carts.list_order_items(cart.id)
      total_price = calculate_total_price(order_items)

      {:ok,
       assign(socket,
         cart: cart,
         user_id: user_id,
         order_items: order_items,
         total_price: total_price
       )}
    else
      {:ok, assign(socket, cart: nil, user_id: nil, order_items: [], total_price: 0)}
    end
  end

  def handle_event("update_quantity", %{"product_id" => product_id, "action" => action}, socket) do
    cart = socket.assigns.cart
    _user_id = socket.assigns.user_id

    case action do
      "increase" -> Carts.update_quantity(cart.id, product_id, 1)
      "decrease" -> Carts.update_quantity(cart.id, product_id, -1)
      _ -> :ok
    end

    order_items = Carts.list_order_items(cart.id)
    total_price = calculate_total_price(order_items)

    {:noreply, assign(socket, order_items: order_items, total_price: total_price)}
  end

  def handle_event("checkout", _params, socket) do
    cart = socket.assigns.cart

    if cart do
      Carts.checkout_cart(cart.id)
    end

    {:noreply, push_navigate(socket, to: "/checkout")}
  end

  defp calculate_total_price(order_items) do
    Enum.reduce(order_items, Decimal.new("0"), fn item, acc ->
      Decimal.add(acc, Decimal.mult(item.product.price, item.quantity))
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Your Cart</h2>
      <%= if @order_items == [] do %>
        <p>Your cart is empty.</p>
      <% else %>
        <ul class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for item <- @order_items do %>
            <li class="bg-white border rounded shadow p-4 mb-2 flex items-center">
              <img src={item.product.image_url} alt={item.product.name} />
              <div class="flex-1">
                <h3 class="font-semibold text-lg mb-1"><%= item.product.name %></h3>
                <p class="text-gray-700 mb-2"><%= item.product.description %></p>
                <p class="text-green-600 font-bold">Price: <%= item.product.price %></p>
                <div class="flex items-center">
                  <button
                    phx-click="update_quantity"
                    phx-value-product_id={item.product.id}
                    phx-value-action="decrease"
                    class="bg-gray-200 p-1 rounded-l"
                  >
                    -
                  </button>
                  <span class="mx-2"><%= item.quantity %></span>
                  <button
                    phx-click="update_quantity"
                    phx-value-product_id={item.product.id}
                    phx-value-action="increase"
                    class="bg-gray-200 p-1 rounded-r"
                  >
                    +
                  </button>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
        <div>
          <form phx-submit="checkout">
            <p class="text-xl font-bold">Total Price: <%= @total_price %></p>
            <br />
            <button type="submit" class="bg-green-500 text-white p-2 rounded hover:bg-green-600">
              Checkout
            </button>
          </form>
        </div>
      <% end %>
    </div>
    """
  end
end
