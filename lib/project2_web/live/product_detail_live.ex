defmodule Project2Web.ProductDetailLive do
  use Phoenix.LiveView
  alias Project2.Products

  alias Project2.Accounts
  alias Project2.Carts
  alias Project2.Wishlists
  alias Project2.Vendors

  def mount(%{"id" => id}, session, socket) do
    product = Products.get_product!(id)
    similar_products = Products.list_products_by_category(product.category_id)
    user_id = get_user_id(session)
    vendor_id = get_vendor_id(session)

    {:ok,
     assign(socket,
       product: product,
       similar_products: similar_products,
       cart_message: nil,
       user_id: user_id,
       vendor_id: vendor_id,
       wishlist_items: get_wishlist_items(user_id)
     )}
  end

  def handle_event("add_to_cart", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns[:user_id]

    if is_nil(user_id) do
      {:noreply, redirect(socket, to: "/users/login")}
    else
      with {:ok, cart} <- get_or_create_cart(user_id),
           {:ok, _order_item} <- Carts.add_to_cart(cart.id, product_id, 1) do
        {:noreply, assign(socket, cart_message: "Product added to cart successfully")}
      else
        _ -> {:noreply, assign(socket, cart_message: "Failed to add product to cart")}
      end
    end
  end

  def handle_event("add_to_wishlist", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns[:user_id]

    if is_nil(user_id) do
      {:noreply, redirect(socket, to: "/users/login")}
    else
      case Wishlists.add_to_wishlist(user_id, product_id) do
        {:ok, _wishlist_item} ->
          {:noreply, assign(socket, cart_message: "Product added to wishlist successfully")}

        _ ->
          {:noreply, assign(socket, cart_message: "Failed to add product to wishlist")}
      end
    end
  end

  defp get_user_id(session) do
    case session["user_token"] do
      nil -> nil
      token -> Accounts.get_user_by_session_token(token) |> Map.get(:id)
    end
  end

  defp get_vendor_id(session) do
    case session["vendor_token"] do
      nil -> nil
      token -> Vendors.get_vendor_by_session_token(token) |> Map.get(:id)
    end
  end

  defp get_or_create_cart(user_id) do
    case Carts.get_cart(user_id) do
      {:ok, cart} -> {:ok, cart}
      {:error, _} -> Carts.create_cart(user_id)
    end
  end

  def handle_event("view_product", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/products/#{id}")}
  end

  defp get_wishlist_items(nil), do: []
  defp get_wishlist_items(user_id), do: Wishlists.list_wishlist_items(user_id)

  def render(assigns) do
    ~H"""
    <header>
      <div class="container mx-auto flex items-center justify-between p-4">
        <a href="/" class="text-xl font-bold">Farm Tools E-Commerce</a>
      </div>
    </header>

    <main class="container mx-auto p-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="p-4 bg-white rounded-lg shadow-md">
          <img src={@product.image_url} alt={@product.name} class="w-full h-auto rounded-md" />
        </div>

        <div>
          <h2 class="text-3xl font-bold mb-4"><%= @product.name %></h2>
          <p class="text-gray-700 mb-4"><%= @product.description %></p>
          <p class="text-green-600 font-bold text-2xl mb-4">Price: Ksh <%= @product.price %></p>

          <div class="flex space-x-2 mb-4">
            <button
              phx-click="add_to_cart"
              phx-value-product_id={@product.id}
              class="p-2 bg-green-500 text-white rounded hover:bg-green-400 shadow-md"
            >
              <i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to Cart
            </button>
            <button
              phx-click="add_to_wishlist"
              phx-value-product_id={@product.id}
              class="p-2 bg-yellow-500 text-white rounded hover:bg-yellow-400 shadow-md"
            >
              <i class="fa fa-heart" aria-hidden="true"></i> Add to Wishlist
            </button>
          </div>

          <%= if @cart_message do %>
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
              <%= @cart_message %>
            </div>
          <% end %>
        </div>
      </div>
      <section class="mt-8">
        <h3 class="text-2xl font-bold mb-4">Reviews</h3>
        <p>No reviews for this product yet</p>
      </section>

      <section class="mt-8">
        <h3 class="text-xl font-bold mb-4">More Products Like This</h3>
        <div class="flex overflow-x-auto space-x-4 p-2">
          <%= for product <- @similar_products do %>
            <div class="min-w-[200px] max-w-[250px] border p-4 rounded-lg shadow-md bg-white flex-shrink-0">
              <img
                src={product.image_url}
                alt={product.name}
                class="w-full h-[150px] object-cover rounded-md"
              />
              <h4 class="font-semibold text-lg mt-2 truncate"><%= product.name %></h4>
              <p class="text-gray-700 mb-2 truncate"><%= product.description %></p>
              <p class="text-green-600 font-bold">Price: Ksh <%= product.price %></p>
              <a href="#" phx-click="view_product" phx-value-id={product.id} class="text-blue-500">
                View Details
              </a>
            </div>
          <% end %>
        </div>
      </section>
    </main>
    """
  end
end
