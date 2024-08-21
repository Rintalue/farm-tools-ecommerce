defmodule Project2.Wishlists.Wishlist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wishlists" do
    belongs_to :user, Project2.Accounts.User
    belongs_to :product, Project2.Products.Product

    timestamps()
  end

  def changeset(wishlist, attrs) do
    wishlist
    |> cast(attrs, [:user_id, :product_id])
    |> validate_required([:user_id, :product_id])
  end
end
