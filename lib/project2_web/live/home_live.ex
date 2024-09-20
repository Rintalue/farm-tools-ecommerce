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
           cart_message: nil,
           navbar_open: false
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
           cart_message: nil,
           navbar_open: false
         )}

      true ->
        {:noreply, redirect(socket, to: "/users/log_in")}
    end
  end

  def handle_event("toggle_navbar", _params, socket) do
    new_state = !socket.assigns.navbar_open
    {:noreply, assign(socket, navbar_open: new_state)}
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
          {:noreply, assign(socket, cart_message: "Failed")}
      end
    else
      IO.puts("User not logged in, cannot add to wishlist")
      {:noreply, put_flash(socket, :error, "User not logged in")}
    end
  end

  def handle_event("view_product", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/products/#{id}")}
  end

  def render(assigns) do
    ~H"""
    <header>
      <div class="container mx-auto flex items-center">
        <button phx-click="toggle_navbar" class="navbar-toggler">
          ☰
        </button>
        &nbsp; <a href="/" class="text-xl font-bold">Farm Tools E-Commerce</a>

        <div class={"navbar-collapse " <> (if @navbar_open, do: "show", else: "hide")}>
          <ul
            class="flex flex-col space-y-4 md:space-y-0 md:flex-row md:space-x-4"
            style="margin:23px;"
          >
            <li><a href="#home" class="hover:text-green-500">Home</a></li>
            <li><a href="/categories" class="hover:text-green-500">Categories</a></li>
            <li><a href="#about" class="hover:text-green-500">About</a></li>
            <li><a href="#contact" class="hover:text-green-500">Contact Us</a></li>
          </ul>
        </div>

        <div class="hidden md:flex items-center space-x-4" style="flex:4;">
          <form phx-submit="search" class="flex" id="search">
            <input
              type="text"
              name="query"
              placeholder="Search products..."
              id="input"
              class="p-2 border border-gray-300 rounded"
            />
            <button type="submit" class="text-green-500 p-2">
              <i class="fa fa-search" aria-hidden="true"></i>
            </button>
          </form>
          <%= if @user_id do %>
            <a href="/cart" class="hover:text-green-500"><i class="fa fa-shopping-cart"></i>Cart</a>
            <a href="/wishlist" class="hover:text-green-500">
              <i class="fa fa-heart"></i>Wishlist
            </a>
            <a href="/user_account" class="hover:text-green-500">
              <i class="fa fa-user"></i> My account
            </a>
            <a href="/vendors/log_in" class="hover:text-red-500">
              <i class="fa fa-user-minus"></i> Logout
            </a>
          <% end %>

          <%= if @vendor_id do %>
            <a href="/vendors/products" class="hover:text-green-500">
              <i class="fas fa-boxes icon"></i> My products
            </a>
            <a href="/vendor_account" class="hover:text-green-500">
              <i class="fa fa-user"></i> My Account
            </a>
            <a href="/users/log_in" class="hover:text-red-500">
              <i class="fa fa-user-minus"></i> Logout
            </a>
          <% end %>
        </div>
      </div>
    </header>

    <main>
      <!-- Hero Section -->
      <section
        id="home"
        class="relative h-screen bg-gray-200 flex items-center justify-center text-center p-4"
      >
        <div
          class="absolute inset-0 bg-cover bg-center"
          style="background-image: url('/images/farmer3.png');"
        >
        </div>
        <div class="relative z-10 text-white">
          <h1 class="text-4xl text-yellow-500 font-bold mb-4">Welcome to Farm Tools E-Commerce</h1>
          <p class="text-lg mb-8">
            Discover the best tools for your farm and garden needs. Quality tools and great prices!
          </p>
          <a href="#products" class="bg-green-500 text-white p-3 rounded hover:bg-green-400">
            Shop Now
          </a>
        </div>
      </section>
      <!-- Products Section -->
      <section id="products" class="p-4">
        <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Products</h2>

        <%= if @cart_message do %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            <%= @cart_message %>
          </div>
        <% end %>

        <ul class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for product <- @products do %>
            <li class="border p-4 rounded shadow-lg relative">
              <button
                phx-click="add_to_wishlist"
                phx-value-product_id={product.id}
                class="absolute top-2 right-2 p-2 bg-yellow-500 text-white rounded hover:bg-yellow-400"
                title="Add to Wishlist"
              >
                <i class="fa fa-heart" aria-hidden="true"></i>
              </button>
              <img src={product.image_url} alt={product.name} />
              <h3 class="font-semibold text-lg mb-2"><%= product.name %></h3>
              <p class="text-green-600 font-bold mb-2">Price: <%= product.price %></p>
              <div class="flex space-x-2">
                <button
                  phx-click="view_product"
                  phx-value-id={product.id}
                  class="p-2 bg-blue-800 text-white rounded hover:bg-blue-400"
                >
                  View Details
                </button>
                <button
                  phx-click="add_to_cart"
                  phx-value-product_id={product.id}
                  class="p-2 bg-green-500 text-white rounded hover:bg-green-400"
                >
                  <i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to Cart
                </button>
              </div>
            </li>
          <% end %>
        </ul>
      </section>
      <!-- About Us Section -->
      <section id="about" class="p-4 bg-white">
        <h2 class="text-center font-bold text-2xl text-green-700 mb-4">About Us</h2>
        <div class="container mx-auto flex flex-col md:flex-row items-center">
          <div class="md:w-1/2">
            <img src="/images/farm4.png" alt="About Us" class="w-full h-auto rounded shadow-lg" />
          </div>
          <div class="md:w-1/2 md:ml-4">
            <p class="text-lg">
              We are dedicated to providing high-quality farm tools to help you get the job done. Our products are selected for their durability and effectiveness, ensuring that you get the best value for your money.
            </p>
            <p class="mt-4">
              Whether you're a professional farmer or a gardening enthusiast, our range of products has something for everyone. Explore our collection and find the perfect tools for your needs.
            </p>
          </div>
        </div>
      </section>
      <!-- Contact Us Section -->
      <section id="contact" class="p-4 bg-gray-100">
        <h2 class="text-center font-bold text-2xl text-green-700 mb-4">Contact Us</h2>
        <div class="container mx-auto">
          <p class="text-lg mb-4">
            We'd love to hear from you! If you have any questions or need assistance, please reach out to us using the contact form below.
          </p>
          <form class="bg-white p-4 rounded shadow-md" action="/contact" method="post">
            <div class="mb-4">
              <label for="name" class="block text-sm font-semibold mb-2">Name:</label>
              <input
                type="text"
                id="name"
                name="name"
                class="w-full p-2 border border-gray-300 rounded"
                required
              />
            </div>
            <div class="mb-4">
              <label for="email" class="block text-sm font-semibold mb-2">Email:</label>
              <input
                type="email"
                id="email"
                name="email"
                class="w-full p-2 border border-gray-300 rounded"
                required
              />
            </div>
            <div class="mb-4">
              <label for="message" class="block text-sm font-semibold mb-2">Message:</label>
              <textarea
                id="message"
                name="message"
                class="w-full p-2 border border-gray-300 rounded"
                rows="4"
                required
              ></textarea>
            </div>
            <button type="submit" class="bg-green-500 text-white p-3 rounded hover:bg-green-400">
              Send Message
            </button>
          </form>
        </div>
      </section>
    </main>
    <nav class="fixed bottom-0 left-0 w-full bg-white shadow-md md:hidden">
      <div class="container mx-auto flex items-center justify-between p-4">
        <form phx-submit="search" class="flex" id="search">
          <input
            type="text"
            name="query"
            placeholder="Search products..."
            id="input"
            class="p-2 border border-gray-300 rounded"
          />
          <button type="submit" class="text-green-500 p-2">
            <i class="fa fa-search" aria-hidden="true"></i>
          </button>

          <div class="flex space-x-4">
            <%= if @user_id do %>
              <a href="/cart" class="hover:text-green-500"><i class="fa fa-shopping-cart"></i></a>
              <a href="/wishlist" class="hover:text-green-500">
                <i class="fa fa-heart"></i>
              </a>
              <a href="/user_account" class="hover:text-green-500">
                <i class="fa fa-user"></i>
              </a>
              <a href="/vendors/log_in" class="hover:text-red-500">
                <i class="fa fa-user-minus"></i>
              </a>
            <% end %>

            <%= if @vendor_id do %>
              <a href="/vendors/products" class="hover:text-green-500">
                <i class="fas fa-boxes icon"></i> My products
              </a>
              <a href="/vendor_account" class="hover:text-green-500">
                <i class="fa fa-user"></i> My Account
              </a>
              <a href="/users/log_in" class="hover:text-red-500">
                <i class="fa fa-user-minus"></i> Logout
              </a>
            <% end %>
          </div>
        </form>
      </div>
    </nav>
    <footer class="bg-gray-800 text-white p-4">
      <div class="container mx-auto text-center">
        <p class="mb-2">© 2024 Farm Tools E-Commerce. All rights reserved.</p>
        <p class="font-semibold mb-2">Contact Us</p>
        <p class="mb-2">
          Email:
          <a href="mailto:info@luthera.com" class="text-gray-400 hover:text-gray-300">
            info@luthera.com
          </a>
        </p>
        <p class="mb-2">
          Phone:
          <a href="tel:+1234567890" class="text-gray-400 hover:text-gray-300">+254-704-00190</a>
        </p>
        <p class="mb-2">Location: 123 Ring Road, Nairobi, Kenya</p>
      </div>
    </footer>
    """
  end
end
