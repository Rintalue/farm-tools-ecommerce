defmodule Project2Web.WishlistLive do
  use Project2Web, :live_view

  alias Project2.Wishlists
  alias Project2.Carts

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    IO.inspect(user_id, label: "User ID in WishlistLive mount")
    wishlist_items = if is_nil(user_id), do: [], else: Wishlists.list_wishlist_items(user_id)

    {:ok,
     assign(socket,
       wishlist_items: wishlist_items,
       user_id: user_id,
       cart_message: nil
     )}
  end

  def handle_event("add_to_cart", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns[:user_id]

    if is_nil(user_id) do
      {:noreply, redirect(socket, to: "/login")}
    else
      with {:ok, cart} <- get_or_create_cart(user_id),
           {:ok, _order_item} <- Carts.add_to_cart(cart.id, product_id, 1) do
        {:noreply, assign(socket, cart_message: "Product added to cart successfully")}
      else
        _ -> {:noreply, assign(socket, cart_message: "Failed to add product to cart")}
      end
    end
  end

  defp get_or_create_cart(user_id) do
    case Carts.get_cart(user_id) do
      {:ok, cart} -> {:ok, cart}
      {:error, _} -> Carts.create_cart(user_id)
    end
  end

  def handle_event("remove_from_wishlist", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns.user_id

    case Wishlists.remove_from_wishlist(user_id, product_id) do
      {:ok, _wishlist} ->
        wishlist_items = Wishlists.list_wishlist_items(user_id)

        {:noreply,
         assign(socket, :wishlist_items, wishlist_items)
         |> put_flash(:info, "Removed from wishlist!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Could not remove from wishlist")}
    end
  end

  def render(assigns) do
    ~H"""
    <header>
      <div class="container mx-auto flex justify-between items-center">
        <h5><a href="/">Farm Tools E-Commerce</a></h5>
      </div>
    </header>
    <main class="p-4">
      <div id="wishlist">
        <h5>Your Wishlist</h5>

        <%= if @wishlist_items != [] do %>
          <ul class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for item <- @wishlist_items do %>
              <li class="border p-4 rounded">
                <img src={item.product.image_url} alt={item.product.name} />
                <h3 class="font-semibold text-lg"><%= item.product.name %></h3>
                <p class="text-green-600 font-bold">Price: <%= item.product.price %></p>
                <button
                  phx-click="add_to_cart"
                  phx-value-product_id={item.product.id}
                  class="p-2 bg-green-500 text-white rounded hover:bg-green-600"
                >
                  Add to Cart
                </button>
                <button
                  <button
                  phx-click="remove_from_wishlist"
                  phx-value-product_id={item.product.id}
                  class="p-2 bg-red-500 text-white rounded hover:bg-red-400"
                >
                  Remove
                </button>
              </li>
            <% end %>
          </ul>
        <% else %>
          <p>Your wishlist is empty.</p>
        <% end %>
        <%= if @cart_message do %>
          <div class="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
            <%= @cart_message %>
          </div>
        <% end %>
      </div>
    </main>
    """
  end
end
