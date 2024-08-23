defmodule Project2Web.MpesaController do
  use Project2Web, :controller

  def callback(conn, params) do
    # Debugging line
    IO.inspect(params, label: "Mpesa Callback Parameters")

    # Handle the callback from Mpesa here
    # You can save the response to the database, log it, etc.

    # Respond to Mpesa to acknowledge receipt of the callback
    conn
    |> put_status(:ok)
    |> json(%{message: "Callback received"})
  end
end
