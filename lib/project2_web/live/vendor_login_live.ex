defmodule Project2Web.VendorLoginLive do
  use Project2Web, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to your Vendor account
        <:subtitle>
          Don't have an account?<br />
          <.link navigate={~p"/vendors/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          to be a Vendor now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/vendors/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/vendors/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "vendor")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
