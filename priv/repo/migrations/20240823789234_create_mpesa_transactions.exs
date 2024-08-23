defmodule Project2.Repo.Migrations.CreateMpesaTransactions do
  use Ecto.Migration

  def change do
    create table(:mpesa_transactions) do
      add :phone_number, :string
      add :amount, :decimal
      add :mpesa_receipt_number, :string
      add :transaction_date, :utc_datetime
      add :status, :string

      timestamps()
    end
  end
end
