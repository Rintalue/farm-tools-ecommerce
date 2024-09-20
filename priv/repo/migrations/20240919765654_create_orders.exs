defmodule Project2.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :quantity, :integer, null: false
      # e.g., "pending", "completed", "failed"
      add :status, :string, null: false
      # If Mpesa payment was used
      add :mpesa_receipt_number, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :shipping_address, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string

      timestamps()
    end

    create index(:orders, [:user_id])
    create index(:orders, [:product_id])
  end
end
