defmodule Project2.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :image_url, :string
    field :name, :string
    field :price, :decimal
    field :vendor_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:image_url, :name, :description, :price, :vendor_id])
    |> validate_required([:image_url, :name, :description, :price, :vendor_id])
    |> validate_length(:name, max: 255)
    |> validate_length(:description, max: 10000)
    |> validate_length(:image_url, max: 9555)
  end
end
