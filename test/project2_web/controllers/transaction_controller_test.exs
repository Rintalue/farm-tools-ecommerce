defmodule Project2Web.TransactionControllerTest do
  use Project2Web.ConnCase

  import Project2.TransactionsFixtures

  alias Project2.Transactions.Transaction

  @create_attrs %{
    amount: "some amount",
    message: "some message",
    status: 42,
    success: true,
    transaction_code: "some transaction_code",
    transaction_reference: "some transaction_reference"
  }
  @update_attrs %{
    amount: "some updated amount",
    message: "some updated message",
    status: 43,
    success: false,
    transaction_code: "some updated transaction_code",
    transaction_reference: "some updated transaction_reference"
  }
  @invalid_attrs %{amount: nil, message: nil, status: nil, success: nil, transaction_code: nil, transaction_reference: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get(conn, ~p"/api/transactions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/transactions", transaction: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/transactions/#{id}")

      assert %{
               "id" => ^id,
               "amount" => "some amount",
               "message" => "some message",
               "status" => 42,
               "success" => true,
               "transaction_code" => "some transaction_code",
               "transaction_reference" => "some transaction_reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/transactions", transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update transaction" do
    setup [:create_transaction]

    test "renders transaction when data is valid", %{conn: conn, transaction: %Transaction{id: id} = transaction} do
      conn = put(conn, ~p"/api/transactions/#{transaction}", transaction: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/transactions/#{id}")

      assert %{
               "id" => ^id,
               "amount" => "some updated amount",
               "message" => "some updated message",
               "status" => 43,
               "success" => false,
               "transaction_code" => "some updated transaction_code",
               "transaction_reference" => "some updated transaction_reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, transaction: transaction} do
      conn = put(conn, ~p"/api/transactions/#{transaction}", transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{conn: conn, transaction: transaction} do
      conn = delete(conn, ~p"/api/transactions/#{transaction}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/transactions/#{transaction}")
      end
    end
  end

  defp create_transaction(_) do
    transaction = transaction_fixture()
    %{transaction: transaction}
  end
end
