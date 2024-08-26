defmodule Project2.Payments.Mpesa do
  @base_url "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
  @shortcode "174379"

  @passkey "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"

  @consumer_key "sNAkVZ5Nrky9BWY8ydDR90msGE8EHapYStmEZcv664RSW871"

  @consumer_secret "zIJAUXFdQqZCFgn5W3ttflZzOt4SZv3Aoq8V6kG75nLI594MpWJshlFGXV3GT6XC"

  def lipa_na_mpesa_online(%{
        phone_number: phone_number,
        amount: amount,
        callback_url: callback_url
      }) do
    IO.inspect(@passkey, label: "MPESA_PASSKEY at runtime")

    IO.inspect(@consumer_key, label: "MPESA_CONSUMER_KEY at runtime")

    IO.inspect(@consumer_secret, label: "MPESA_CONSUMER_SECRET at runtime")

    timestamp = Timex.format!(Timex.now(), "%Y%m%d%H%M%S", :strftime)

    password = Base.encode64(@shortcode <> @passkey <> timestamp)

    payload = %{
      "BusinessShortCode" => @shortcode,
      "Password" => password,
      "Timestamp" => timestamp,
      "TransactionType" => "CustomerPayBillOnline",
      "Amount" => amount,
      "PartyA" => 254_705_357_840,
      "PartyB" => @shortcode,
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
            IO.puts("Access Token: #{access_token}")
            access_token

          {:error, reason} ->
            IO.inspect(reason, label: "Error decoding response")
            nil
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to get token, status: #{status_code}, body: #{body}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "HTTPoison error")
        nil
    end
  end
end
