defmodule Project2.Payments.MpesaTransactions do
  alias Project2.Repo
  alias Project2.Payments.MpesaTransaction

  def process_callback(%{"ResultCode" => result_code, "CallbackMetadata" => metadata}) do
    case result_code do
      0 ->
        # Payment was successful
        process_successful_payment(metadata)

      _ ->
        # Payment failed
        process_failed_payment(metadata, result_code)
    end
  end

  defp process_successful_payment(%{"Item" => items}) do
    phone_number = get_metadata_item(items, "PhoneNumber")
    amount = get_metadata_item(items, "Amount")
    mpesa_receipt_number = get_metadata_item(items, "MpesaReceiptNumber")
    transaction_date = get_metadata_item(items, "TransactionDate")

    %MpesaTransaction{}
    |> MpesaTransaction.changeset(%{
      phone_number: phone_number,
      amount: Decimal.new(amount),
      mpesa_receipt_number: mpesa_receipt_number,
      transaction_date: parse_transaction_date(transaction_date),
      status: "completed"
    })
    |> Repo.insert()
  end

  defp process_failed_payment(%{"Item" => items}, _result_code) do
    phone_number = get_metadata_item(items, "PhoneNumber")
    amount = get_metadata_item(items, "Amount")
    mpesa_receipt_number = get_metadata_item(items, "MpesaReceiptNumber")
    transaction_date = get_metadata_item(items, "TransactionDate")

    %MpesaTransaction{}
    |> MpesaTransaction.changeset(%{
      phone_number: phone_number,
      amount: Decimal.new(amount),
      mpesa_receipt_number: mpesa_receipt_number,
      transaction_date: parse_transaction_date(transaction_date),
      status: "failed"
    })
    |> Repo.insert()
  end

  defp get_metadata_item(items, key) do
    Enum.find_value(items, fn %{"Name" => name, "Value" => value} ->
      if name == key, do: value
    end)
  end

  defp parse_transaction_date(date_string) do
    # Parse the transaction date from the callback format
    Timex.parse!(date_string, "{YYYY}{0M}{0D}{h24}{m}{s}")
  end
end
