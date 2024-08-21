defmodule Project2.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :string
    field :message, :string
    field :status, :integer
    field :success, :boolean, default: false
    field :transaction_code, :string
    field :transaction_reference, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :message,
      :success,
      :status,
      :amount,
      :transaction_code,
      :transaction_reference
    ])
    |> validate_required([:success, :status, :transaction_reference])
  end
end
