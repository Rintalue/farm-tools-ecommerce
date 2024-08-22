defmodule Project2.Payments do
  @moduledoc """
  Module to handle payment processing with Stripe.
  """
  @stripe_api_key "sk_test_51Pq9URRuHbT5mBnoglmp644ioyzgY6JMRfPC871SCK107bKPmQmlhTfHSaTBCKHa7Oi4P4pmaD5rhXJO1hpHbA7J00bgacyzmq"

  def create_payment_intent(_user_id) do
    # Use the Stripe Elixir library or HTTPoison to make API calls
    # Example with HTTPoison:
    url = "https://api.stripe.com/v1/payment_intents"

    headers = [
      {"Authorization", "Bearer #{@stripe_api_key}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    body =
      URI.encode_query(%{
        # Replace with the total amount in cents
        "amount" => "1000",
        "currency" => "usd",
        "payment_method_types[]" => "card"
      })

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, Poison.decode!(body)["client_secret"]}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
