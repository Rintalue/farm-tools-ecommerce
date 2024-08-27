defmodule Project2Web.MpesaController do
  use Project2Web, :controller

  def callback(conn, params) do
    # check if anyhting is really happening cause i cant see anything
    IO.inspect(params, label: "Mpesa Callback Parameters")

    # Handle the callback from Mpesa here
    # will save the response to the database here later.

    conn
    |> put_status(:ok)
    |> json(%{message: "Callback received"})
  end
end
