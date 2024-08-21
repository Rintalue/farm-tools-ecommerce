defmodule Project2.Repo.Migrations.CreateWishlists do
  use Ecto.Migration

  def change do
    create table(:wishlist) do
      add :user_id, references(:users, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:wishlists, [:user_id, :product_id])
  end
end
