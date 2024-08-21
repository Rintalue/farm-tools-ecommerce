defmodule Project2Web.VendorProductLive do
  use Phoenix.LiveView

  alias Project2.Products
  alias Project2.Products.Product

  def mount(_params, _session, socket) do
    current_vendor = get_current_vendor(socket)

    products =
      if current_vendor do
        Products.list_products(current_vendor.id)
      else
        []
      end

    {:ok,
     socket
     |> assign(:current_vendor, current_vendor)
     |> assign(:changeset, Products.change_product(%Product{}))
     |> assign(:products, products)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    current_vendor = socket.assigns.current_vendor

    if current_vendor do
      product_params = Map.put(product_params, "vendor_id", current_vendor.id)

      case Products.create_product(product_params) do
        {:ok, _product} ->
          products = Products.list_products_by_vendor(current_vendor.id)

          {:noreply,
           socket
           |> put_flash(:info, "Product added successfully.")
           |> assign(:products, products)
           |> push_navigate(to: "/")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp get_current_vendor(socket) do
    socket.assigns.current_vendor
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Add a Product</h1>
    <form phx-submit="save">
      <label for="product_image_url">Image URL</label>
      <input
        type="text"
        name="product[image_url]"
        id="product_image_url"
        value={@changeset.data.image_url || ""}
      />
      <%= error_tag(@changeset, :image_url) %>

      <label for="product_name">Name</label>
      <input type="text" name="product[name]" id="product_name" value={@changeset.data.name || ""} />
      <%= error_tag(@changeset, :name) %>

      <label for="product_description">Description</label>
      <textarea name="product[description]" id="product_description">
        <%= @changeset.data.description || "" %>
      </textarea>
      <%= error_tag(@changeset, :description) %>

      <label for="product_price">Price</label>
      <input
        type="number"
        name="product[price]"
        id="product_price"
        value={@changeset.data.price || ""}
      />
      <%= error_tag(@changeset, :price) %>

      <button class="submit" type="submit">Add Product</button>
    </form>

    <h1>Your Products</h1>
    <span class="products">
      <ul>
        <%= for product <- @products do %>
          <li style="line-height:34px;">
            <img src={product.image_url} alt={product.name} />
            <h3><%= product.name %></h3>
            <p><%= product.description %></p>
            <p>Price: <%= product.price %></p>
            <a class="submit2" href={"/products/#{product.id}/edit"}>Edit</a>
          </li>
        <% end %>
      </ul>
    </span>
    """
  end

  defp error_tag(changeset, field) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    error_message = Map.get(errors, field, "")

    if error_message != "" do
      Phoenix.HTML.raw("<span class=\"error\">#{error_message}</span>")
    else
      ""
    end
  end
end
