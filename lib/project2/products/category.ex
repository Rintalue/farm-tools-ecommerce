defmodule Project2.Products.Category do
  use Ecto.Schema

  schema "categories" do
    field :name, :string
    timestamps()
  end
end
