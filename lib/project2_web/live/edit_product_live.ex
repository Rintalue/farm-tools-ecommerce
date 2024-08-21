defmodule Project2Web.EditProductLive do
  use Phoenix.LiveView

  alias Project2.Products

  def mount(%{"id" => id}, _session, socket) do
    product = Products.get_product!(id)
    changeset = Products.change_product(product)
    {:ok, assign(socket, changeset: changeset, product: product)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    product = socket.assigns.product

    case Products.update_product(product, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully.")
         |> push_navigate(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)

    case Products.delete_product(product) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product deleted successfully.")
         |> push_navigate(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Edit Product</h1>
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

      <button class="submit" type="submit">Save Product</button>
    </form>

    <button class="submit " phx-click="delete" phx-value-id={@product.id}>Delete Product</button>
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
