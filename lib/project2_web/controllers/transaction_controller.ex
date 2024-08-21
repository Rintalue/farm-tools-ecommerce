defmodule Project2Web.TransactionController do
  use Project2Web, :controller

  alias Project2.Transactions
  alias Project2.Transactions.Transaction

  action_fallback Project2Web.FallbackController

  def index(conn, _params) do
    transactions = Transactions.list_transactions()
    render(conn, :index, transactions: transactions)
  end

  def create(conn, transaction_params) do
    new_transaction_params = %{
      "message" => transaction_params["Message"],
      "success" => transaction_params["Success"],
      "status" => transaction_params["Status"],
      "amount" => transaction_params["Amount"],
      "transaction_code" => transaction_params["transaction_code"],
      "transaction_reference" => transaction_params["transaction_reference"]
    }

    with {:ok, %Transaction{} = transaction} <-
           Transactions.create_transaction(new_transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/transactions/#{transaction}")
      |> render(:show, transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, :show, transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_transaction!(id)

    with {:ok, %Transaction{} = transaction} <-
           Transactions.update_transaction(transaction, transaction_params) do
      render(conn, :show, transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)

    with {:ok, %Transaction{}} <- Transactions.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
