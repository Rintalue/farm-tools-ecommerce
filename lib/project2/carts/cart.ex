defmodule Project2.Carts.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    belongs_to :user, Project2.Accounts.User
    has_many :order_items, Project2.Carts.OrderItem
    timestamps()
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
