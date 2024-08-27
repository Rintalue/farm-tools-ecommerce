defmodule Project2.Carts do
  alias Project2.Repo
  alias Project2.Carts.{Cart, OrderItem}
  import Ecto.Query, only: [from: 2]

  def create_cart(user_id) do
    %Cart{}
    |> Cart.changeset(%{user_id: user_id})
    |> Repo.insert()
  end

  @spec get_cart(any()) :: {:error, <<_::112>>} | {:ok, any()}
  def get_cart(user_id) do
    case Repo.one(from(c in Cart, where: c.user_id == ^user_id)) do
      nil -> {:error, "Cart not found"}
      cart -> {:ok, cart}
    end
  end

  def add_to_cart(cart_id, product_id, quantity) do
    IO.inspect({cart_id, product_id, quantity}, label: "Adding to Cart")

    order_item_query =
      from oi in OrderItem,
        where: oi.cart_id == ^cart_id and oi.product_id == ^product_id

    case Repo.one(order_item_query) do
      nil ->
        %OrderItem{}
        |> OrderItem.changeset(%{cart_id: cart_id, product_id: product_id, quantity: quantity})
        |> Repo.insert()

      existing_item ->
        updated_quantity = existing_item.quantity + quantity

        existing_item
        |> OrderItem.changeset(%{quantity: updated_quantity})
        |> Repo.update()
    end
  end

  def list_order_items(cart_id) do
    query =
      from oi in OrderItem,
        where: oi.cart_id == ^cart_id,
        preload: [:product]

    Repo.all(query)
  end

  def checkout_cart(cart_id) do
    order_items = list_order_items(cart_id)

    Enum.each(order_items, fn item ->
      item
      |> OrderItem.changeset(%{status: "pending"})
      |> Repo.update()
    end)
  end

  def update_order_status(order_id, status) do
    order = Repo.get!(OrderItem, order_id)

    order
    |> OrderItem.changeset(%{status: status})
    |> Repo.update()
  end

  def list_orders_by_user(user_id) do
    Repo.all(
      from o in OrderItem,
        join: c in Cart,
        on: o.cart_id == c.id,
        where: c.user_id == ^user_id,
        preload: [:product]
    )
  end

  def list_orders_by_vendor(vendor_id) do
    Repo.all(
      from o in OrderItem,
        join: p in assoc(o, :product),
        where: p.vendor_id == ^vendor_id,
        preload: [:product]
    )
  end

  def update_quantity(cart_id, product_id, quantity_change) do
    order_item = Repo.get_by(OrderItem, cart_id: cart_id, product_id: product_id)

    if order_item do
      new_quantity = order_item.quantity + quantity_change

      if new_quantity > 0 do
        order_item
        |> OrderItem.changeset(%{quantity: new_quantity})
        |> Repo.update()
      else
        Repo.delete(order_item)
      end
    else
      {:error, :order_item_not_found}
    end
  end

  def update_order_status(checkout_request_id, status, receipt_number, amount) do
    order_item = Repo.get_by(OrderItem, checkout_request_id: checkout_request_id)

    changeset =
      OrderItem.changeset(order_item, %{
        status: status,
        mpesa_receipt_number: receipt_number,
        amount_paid: amount
      })

    Repo.update(changeset)
  end
end
