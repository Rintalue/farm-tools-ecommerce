defmodule Project2.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Project2.Repo

  alias Project2.Carts.OrderItem

  alias Project2.Products.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  def list_products_by_vendor(vendor_id) do
    from(p in Product, where: p.vendor_id == ^vendor_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of products for a specific vendor.

  ## Examples

      iex> list_products(vendor_id)
      [%Product{}, ...]

  """
  def list_products(vendor_id) do
    Repo.all(from p in Product, where: p.vendor_id == ^vendor_id)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def search_products_by_name(query) do
    from(p in Product, where: ilike(p.name, ^"%#{query}%"))
    |> Repo.all()
  end

  def get_vendor_sales(vendor_id) do
    products = Repo.all(from p in Product, where: p.vendor_id == ^vendor_id)

    Enum.map(products, fn product ->
      items =
        Repo.all(from o in OrderItem, where: o.product_id == ^product.id and o.status == "paid")

      {product, items}
    end)
  end
end
