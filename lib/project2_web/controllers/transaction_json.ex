defmodule Project2Web.TransactionJSON do
  alias Project2.Transactions.Transaction

  @doc """
  Renders a list of transactions.
  """
  def index(%{transactions: transactions}) do
    %{data: for(transaction <- transactions, do: data(transaction))}
  end

  @doc """
  Renders a single transaction.
  """
  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      message: transaction.message,
      success: transaction.success,
      status: transaction.status,
      amount: transaction.amount,
      transaction_code: transaction.transaction_code,
      transaction_reference: transaction.transaction_reference
    }
  end
end
