defmodule Project2.Orders do
  import Ecto.Query, warn: false
  alias Project2.Repo
  alias Project2.Orders.Order

  @doc """
  Creates an order.
  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetches orders for a specific user.
  """
  def get_orders_by_user(user_id) do
    Repo.all(from order in Order, where: order.user_id == ^user_id)
  end

  def get_orders_by_user_by_receipt(receipt_number) do
    Repo.all(from order in Order, where: order.mpesa_receipt_number == ^receipt_number)
  end

  @doc """
  Fetches a single order by its ID.
  """
  def get_order!(id) do
    Repo.get!(Order, id)
  end

  @doc """
  Updates an order.
  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an order.
  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Lists all orders for a user.
  """
  def list_user_orders(user_id) do
    Order
    |> where([o], o.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Lists all pending orders for a user.
  """
  def list_pending_orders(user_id) do
    Order
    |> where([o], o.user_id == ^user_id and o.status == "pending")
    |> Repo.all()
  end
end
