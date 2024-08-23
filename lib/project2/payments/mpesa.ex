defmodule Project2.Payments.Mpesa do
  @base_url "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
  @shortcode "174379"
  # Replace with your actual passkey
  @passkey "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
  # Replace with your actual consumer key
  @consumer_key "sNAkVZ5Nrky9BWY8ydDR90msGE8EHapYStmEZcv664RSW871"
  # Replace with your actual consumer secret
  @consumer_secret "zIJAUXFdQqZCFgn5W3ttflZzOt4SZv3Aoq8V6kG75nLI594MpWJshlFGXV3GT6XC"

  def lipa_na_mpesa_online(%{
        phone_number: phone_number,
        amount: amount,
        callback_url: callback_url
      }) do
    # Debugging line
    IO.inspect(@passkey, label: "MPESA_PASSKEY at runtime")
    # Debugging line
    IO.inspect(@consumer_key, label: "MPESA_CONSUMER_KEY at runtime")
    # Debugging line
    IO.inspect(@consumer_secret, label: "MPESA_CONSUMER_SECRET at runtime")

    timestamp =
      :os.system_time(:second)
      |> DateTime.from_unix!()
      |> DateTime.to_iso8601()

    password = Base.encode64(@shortcode <> @passkey <> timestamp)

    payload = %{
      "BusinessShortCode" => @shortcode,
      "Password" => password,
      "Timestamp" => timestamp,
      "TransactionType" => "CustomerPayBillOnline",
      "Amount" => amount,
      # Make sure this is not an empty string
      "PartyA" => 254_705_357_840,
      # No quotes needed here
      "PartyB" => @shortcode,
      # Make sure this is not an empty string
      "PhoneNumber" => phone_number,
      "CallBackURL" => callback_url,
      "AccountReference" => "Luthera",
      "TransactionDesc" => "Payment of X"
    }

    headers = [{"Authorization", "Bearer " <> get_access_token()}]

    IO.inspect(payload, label: "Request Payload")
    IO.inspect(headers, label: "Request Headers")

    HTTPoison.post(@base_url, Jason.encode!(payload), headers, [
      {"Content-Type", "application/json"}
    ])
  end

  defp get_access_token do
    auth_url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{@consumer_key}:#{@consumer_secret}")}
    ]

    case HTTPoison.get(auth_url, headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        case Jason.decode(body) do
          {:ok, %{"access_token" => access_token}} ->
            # Debugging line
            IO.puts("Access Token: #{access_token}")
            access_token

          {:error, reason} ->
            IO.inspect(reason, label: "Error decoding response")
            nil
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        # Debugging line
        IO.puts("Failed to get token, status: #{status_code}, body: #{body}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "HTTPoison error")
        nil
    end
  end
end
