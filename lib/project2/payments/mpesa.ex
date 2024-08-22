defmodule Project2.Payments.Mpesa do
  @base_url "https://sandbox.safaricom.co.ke"

  def lipa_na_mpesa_online(%{
        phone_number: phone_number,
        amount: amount,
        callback_url: callback_url
      }) do
    url = "#{@base_url}/mpesa/stkpush/v1/processrequest"
    access_token = get_access_token()

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    body =
      %{
        "BusinessShortCode" => System.get_env("174379"),
        "Password" => generate_password(),
        "Timestamp" => timestamp(),
        "TransactionType" => "CustomerPayBillOnline",
        "Amount" => amount,
        "PartyA" => phone_number,
        "PartyB" => System.get_env("174379"),
        "PhoneNumber" => phone_number,
        "CallBackURL" => callback_url,
        "AccountReference" => "AccountRef",
        "TransactionDesc" => "Payment Description"
      }
      |> Jason.encode!()

    HTTPoison.post(url, body, headers)
  end

  defp get_access_token() do
    url = "#{@base_url}/oauth/v1/generate?grant_type=client_credentials"
    key = System.get_env("sNAkVZ5Nrky9BWY8ydDR90msGE8EHapYStmEZcv664RSW871")
    secret = System.get_env("zIJAUXFdQqZCFgn5W3ttflZzOt4SZv3Aoq8V6kG75nLI594MpWJshlFGXV3GT6XC")

    {:ok, response} = HTTPoison.get(url, [], hackney: [basic_auth: {key, secret}])
    body = Jason.decode!(response.body)
    body["access_token"]
  end

  defp generate_password do
    shortcode = System.get_env("174379")
    passkey = System.get_env("bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919")
    timestamp = timestamp()

    Base.encode64("#{shortcode}#{passkey}#{timestamp}")
  end

  defp timestamp do
    DateTime.utc_now()
    |> DateTime.to_string()
    |> String.replace("-", "")
    |> String.replace(":", "")
    |> String.replace(" ", "")
  end
end
