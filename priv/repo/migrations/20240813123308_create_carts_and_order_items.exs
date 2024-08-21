defmodule Project2.Repo.Migrations.CreateCartsAndOrderItems do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create table(:order_items) do
      add :cart_id, references(:carts, on_delete: :delete_all)
      add :product_id, references(:products, on_delete: :nothing)
      add :quantity, :integer
      timestamps()
    end

    create index(:order_items, [:cart_id])
    create index(:order_items, [:product_id])
  end
end
