defmodule Project2Web.HomeLive do
  use Phoenix.LiveView
  alias Project2.Products
  alias Project2.Carts
  alias Project2.Wishlists
  alias Project2.Accounts
  alias Project2.Vendors

  def mount(_params, session, socket) do
    user_id =
      case session["user_token"] do
        nil -> nil
        user_token -> Accounts.get_user_by_session_token(user_token) |> Map.get(:id)
      end

    vendor_id =
      case session["vendor_token"] do
        nil -> nil
        vendor_token -> Vendors.get_vendor_by_session_token(vendor_token) |> Map.get(:id)
      end

    cond do
      user_id ->
        products = Products.list_products()
        wishlist_items = Wishlists.list_wishlist_items(user_id)

        {:ok,
         assign(socket,
           products: products,
           wishlist_items: wishlist_items,
           user_id: user_id,
           vendor_id: nil,
           query: "",
           cart_message: nil
         )}

      vendor_id ->
        products = Products.list_products()

        {:ok,
         assign(socket,
           products: products,
           wishlist_items: [],
           user_id: nil,
           vendor_id: vendor_id,
           query: "",
           cart_message: nil
         )}

      true ->
        {:noreply, redirect(socket, to: "/users/log_in")}
    end
  end

  def handle_event("search", %{"query" => query}, socket) do
    IO.inspect(query, label: "Search Query")
    products = Products.search_products_by_name(query)
    {:noreply, assign(socket, products: products, query: query)}
  end

  def handle_event("add_to_cart", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns[:user_id]

    IO.inspect(user_id, label: "User ID in add_to_cart")

    if is_nil(user_id) do
      IO.puts("User not logged in, redirecting to log in page")
      {:noreply, push_navigate(socket, to: "/users/log_in")}
    else
      cart =
        case Carts.get_cart(user_id) do
          {:ok, existing_cart} ->
            existing_cart

          {:error, _reason} ->
            {:ok, new_cart} = Carts.create_cart(user_id)
            new_cart
        end

      case Carts.add_to_cart(cart.id, product_id, 1) do
        {:ok, _order_item} ->
          IO.puts("Product added to cart successfully")
          {:noreply, assign(socket, cart_message: "Product added successfully")}

        {:error, _reason} ->
          IO.puts("Failed to add product to cart")
          {:noreply, assign(socket, cart_message: "Failed to add product to cart")}
      end
    end
  end

  def handle_event("add_to_wishlist", %{"product_id" => product_id}, socket) do
    user_id = socket.assigns[:user_id]

    IO.inspect(user_id, label: "User ID in add_to_wishlist")

    if user_id do
      case Wishlists.add_to_wishlist(user_id, product_id) do
        {:ok, _wishlist} ->
          IO.puts("Product added to wishlist successfully")
          {:noreply, assign(socket, cart_message: "Added to wishlist successfully")}

        {:error, _changeset} ->
          IO.puts("Failed to add product to wishlist")
          {:noreply, assign(socket, cart_message: " Failed")}
      end
    else
      IO.puts("User not logged in, cannot add to wishlist")
      {:noreply, put_flash(socket, :error, "User not logged in")}
    end
  end

  def render(assigns) do
    ~H"""
    <header>
      <div class="container mx-auto flex justify-between items-center">
        <h5><a href="/">Farm Tools E-Commerce</a></h5>

        <div class="hidden md:flex items-center space-x-4">
          <form phx-submit="search" class="flex" id="search">
            <input type="text" name="query" placeholder="Search products..." id="input" />
            <button type="submit" class="text-green-500 p-2">
              <i class="fa fa-search" aria-hidden="true"></i>
            </button>
          </form>
        </div>
      </div>
    </header>
    <main class="p-4">
      <section>
        <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Products</h2>

        <%= if @cart_message do %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            <%= @cart_message %>
          </div>
        <% end %>

        <ul class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for product <- @products do %>
            <li class="border p-4 rounded">
              <img src={product.image_url} alt={product.name} />
              <h3 class="font-semibold text-lg"><%= product.name %></h3>
              <p class="text-gray-700 mb-2"><%= product.description %></p>
              <p class="text-green-600 font-bold">Price: <%= product.price %></p>
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
                  class="p-2 bg-blue-900 text-white rounded hover:bg-blue-400"
                >
                  <i class="fa fa-heart" aria-hidden="true"></i> Add to Wishlist
                </button>
              </div>
            </li>
          <% end %>
        </ul>
      </section>
    </main>
    <footer>
      <section class="icons-container grid grid-cols-2 md:grid-cols-4 gap-4 p-4">
        <div class="icons">
          <i class="fa fa-plane"></i>
          <div class="content">
            <h3>Free Shipping</h3>
            <p>Order over Kshs.1000</p>
          </div>
        </div>
        <div class="icons">
          <i class="fa fa-lock"></i>
          <div class="content">
            <h3>Secure Payment</h3>
            <p>For the best experience</p>
          </div>
        </div>
        <div class="icons">
          <i class="fa fa-undo"></i>
          <div class="content">
            <h3>Easier Returns</h3>
            <p>10 day return period</p>
          </div>
        </div>
        <div class="icons">
          <i class="fa fa-gift"></i>
          <div class="content">
            <h3>Gift Shop</h3>
            <p>Available all year round</p>
          </div>
        </div>
      </section>
    </footer>
    """
  end
end
