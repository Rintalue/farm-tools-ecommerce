defmodule Project2.Payments.MpesaTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mpesa_transactions" do
    field :phone_number, :string
    field :amount, :decimal
    field :mpesa_receipt_number, :string
    field :transaction_date, :utc_datetime
    field :status, :string

    timestamps()
  end

  def changeset(mpesa_transaction, attrs) do
    mpesa_transaction
    |> cast(attrs, [:phone_number, :amount, :mpesa_receipt_number, :transaction_date, :status])
    |> validate_required([
      :phone_number,
      :amount,
      :mpesa_receipt_number,
      :transaction_date,
      :status
    ])
  end
end
