defmodule Project2Web.MpesaController do
  use Project2Web, :controller

  def callback(conn, %{"Body" => %{"stkCallback" => %{"ResultCode" => result_code}}}) do
    case result_code do
      0 ->
        # Payment was successful, update order status yesss :)
        conn |> send_resp(200, "Success")

      _ ->
        # Payment failed :(
        conn |> send_resp(400, "Failure")
    end
  end
end
