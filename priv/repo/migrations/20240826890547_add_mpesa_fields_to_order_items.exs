defmodule Project2.Repo.Migrations.AddMpesaFieldsToOrderItems do
  use Ecto.Migration

  def change do
    alter table(:order_items) do
      add :mpesa_receipt_number, :string
      add :amount_paid, :float
      add :checkout_request_id, :string
    end
  end
end
