defmodule Project2.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Project2.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: "some amount",
        message: "some message",
        status: 42,
        success: true,
        transaction_code: "some transaction_code",
        transaction_reference: "some transaction_reference"
      })
      |> Project2.Transactions.create_transaction()

    transaction
  end
end
