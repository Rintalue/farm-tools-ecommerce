defmodule Project2.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :quantity, :integer
    field :status, :string
    field :mpesa_receipt_number, :string
    field :shipping_address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string

    belongs_to :user, Project2.Accounts.User
    belongs_to :product, Project2.Products.Product

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :quantity,
      :status,
      :mpesa_receipt_number,
      :shipping_address,
      :city,
      :state,
      :zip_code,
      :user_id,
      :product_id
    ])
    |> validate_required([:quantity, :status, :user_id, :product_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:product)
  end
end
