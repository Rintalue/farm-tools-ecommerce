defmodule Project2Web.CategoryLive do
  use Project2Web, :live_view

  alias Project2.Products
  alias Project2.Accounts
  alias Project2.Carts
  alias Project2.Wishlists
  alias Project2.Vendors

  def mount(_params, session, socket) do
    user_id = get_user_id(session)
    vendor_id = get_vendor_id(session)

    categories = Products.list_categories()
    products_grouped = Products.list_products_grouped_by_category()

    {:ok,
     assign(socket,
       categories: categories,
       products_grouped: products_grouped,
       selected_category_id: nil,
       user_id: user_id,
       vendor_id: vendor_id,
       cart_message: nil,
       wishlist_items: get_wishlist_items(user_id)
     )}
  end

  def handle_event("select_category", %{"category_id" => category_id}, socket) do
    category_id = String.to_integer(category_id)
    products = Products.list_products_by_category(category_id)

    {:noreply,
     assign(socket,
       selected_category_id: category_id,
       products: products
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

  defp get_wishlist_items(nil), do: []
  defp get_wishlist_items(user_id), do: Wishlists.list_wishlist_items(user_id)

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold mb-6 text-center">Categories</h1>
      <div class="flex overflow-x-auto pb-4 mb-6 border-b border-gray-200">
        <%= for category <- @categories do %>
          <button
            phx-click="select_category"
            phx-value-category_id={category.id}
            class={
              "p-4 border rounded-lg text-center mx-2 whitespace-nowrap transition-colors duration-300 " <>
                if @selected_category_id == category.id, do: "bg-green-600 text-white", else: "bg-gray-200"
            }
          >
            <%= category.name %>
          </button>
        <% end %>
      </div>

      <%= if @selected_category_id do %>
        <h2 class="text-2xl font-semibold mb-6 text-center">
          Products in <%= Enum.find(@categories, fn c -> c.id == @selected_category_id end).name %>
        </h2>
        <%= if @products == [] do %>
          <p>No products available in this category.</p>
        <% else %>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for product <- @products do %>
              <div class="border rounded-lg shadow-lg p-4 bg-white max-w-xs mx-auto">
                <img src={product.image_url} alt={product.name} />
                <h3 class="text-lg font-semibold mb-2 text-center"><%= product.name %></h3>
                <p class="text-gray-700 mb-2 text-center"><%= product.description %></p>
                <p class="text-green-600 font-bold mb-4 text-center"><%= product.price %> ksh</p>
                <div class="flex space-x-2">
                  <button
                    phx-click="add_to_cart"
                    phx-value-product_id={product.id}
                    class="p-2 bg-green-500 text-white rounded hover:bg-green-400"
                  >
                    <i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to Cart
                  </button>
                  <button
                    phx-click="add_to_wishlist"
                    phx-value-product_id={product.id}
                    class="p-2 bg-yellow-500 text-white rounded hover:bg-blue-400"
                  >
                    <i class="fa fa-heart" aria-hidden="true"></i> Add to Wishlist
                  </button>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      <% else %>
        <p>Select a category to view products.</p>
      <% end %>

      <%= if @cart_message do %>
        <div class="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
          <%= @cart_message %>
        </div>
      <% end %>
    </div>
    """
  end
end
