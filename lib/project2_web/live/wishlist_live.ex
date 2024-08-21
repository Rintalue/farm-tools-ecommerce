defmodule Project2Web.WishlistLive do
  use Project2Web, :live_view

  alias Project2.Wishlists

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id |> IO.inspect()
    IO.inspect(user_id, label: "User ID in WishlistLive mount")
    wishlist_items = if is_nil(user_id), do: [], else: Wishlists.list_wishlist_items(user_id)

    {:ok,
     assign(socket,
       wishlist_items: wishlist_items,
       user_id: user_id
     )}
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
      </div>
    </main>
    """
  end
end
