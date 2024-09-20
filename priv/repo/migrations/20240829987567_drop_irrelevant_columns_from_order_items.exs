defmodule YourApp.Repo.Migrations.DropIrrelevantColumnsFromOrderItems do
  use Ecto.Migration

  def change do
    alter table(:order_items) do
      remove :status
      remove :mpesa_receipt_number
      remove :amount_paid
      remove :checkout_request_id
    end
  end
end
