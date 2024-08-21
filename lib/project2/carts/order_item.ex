defmodule Project2.Carts.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    belongs_to :cart, Project2.Carts.Cart
    belongs_to :product, Project2.Products.Product
    field :quantity, :integer
    field :status, :string, default: "pending"
    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:cart_id, :product_id, :quantity])
    |> validate_required([:cart_id, :product_id, :quantity])
  end
end
