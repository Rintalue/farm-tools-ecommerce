defmodule Project2Web.MpesaController do
  use Project2Web, :controller
  alias Project2.Orders

  alias Project2.Payments.MpesaTransactions
  require Logger

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(conn, %{
        "Body" => %{"stkCallback" => %{"ResultCode" => result_code} = callback_data}
      }) do
    IO.inspect(callback_data, label: "M-Pesa Callback Data")
    Logger.info("Received M-Pesa callback")

    # Handle successful callback (ResultCode 0 means success)
    case result_code do
      0 ->
        handle_successful_callback(callback_data)
        Logger.info("M-Pesa transaction successful: #{inspect(callback_data)}")

      _ ->
        handle_failed_callback(callback_data)
        Logger.warn("M-Pesa transaction failed: #{inspect(callback_data)}")
    end

    # Respond to M-Pesa to acknowledge receipt of the callback
    conn
    |> put_status(:ok)
    |> json(%{message: "Callback received"})
  end

  # Function to handle a successful M-Pesa transaction
  defp handle_successful_callback(%{
         "CallbackMetadata" => %{"Item" => items},
         "CheckoutRequestID" => checkout_request_id,
         "MerchantRequestID" => merchant_request_id
       }) do
    # Extract necessary data from the items
    amount = get_callback_item_value(items, "Amount")
    receipt_number = get_callback_item_value(items, "MpesaReceiptNumber")
    phone_number = get_callback_item_value(items, "PhoneNumber")
    transaction_date = get_callback_item_value(items, "TransactionDate")

    # Process this data (e.g., store in the database, trigger business logic, etc.)
    # Store M-Pesa transaction
    MpesaTransactions.process_callback(%{
      "ResultCode" => 0,
      "CallbackMetadata" => %{"Item" => items}
    })

    # Mark the corresponding order as completed
    Orders.get_orders_by_user_by_receipt(receipt_number)
    |> Enum.each(fn order ->
      Orders.update_order(order, %{status: "completed", mpesa_receipt_number: receipt_number})
    end)

    Logger.info("""
    Successful M-Pesa Transaction:
      Amount: #{amount}
      Receipt Number: #{receipt_number}
      Phone Number: #{phone_number}
      Transaction Date: #{transaction_date}
      Checkout Request ID: #{checkout_request_id}
      Merchant Request ID: #{merchant_request_id}
    """)
  end

  # Function to handle a failed M-Pesa transaction
  defp handle_failed_callback(%{
         "ResultDesc" => result_desc,
         "CheckoutRequestID" => checkout_request_id,
         "MerchantRequestID" => merchant_request_id
       }) do
    # Log the failure or handle it accordingly
    Logger.warn("""
    Failed M-Pesa Transaction:
      Reason: #{result_desc}
      Checkout Request ID: #{checkout_request_id}
      Merchant Request ID: #{merchant_request_id}
    """)
  end

  # Helper function to get the value of an item from the callback metadata
  defp get_callback_item_value(items, name) do
    items
    |> Enum.find(fn %{"Name" => n} -> n == name end)
    |> Map.get("Value")
  end

  def get_error(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "This route only accepts POST requests."})
  end
end
