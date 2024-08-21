defmodule Project2Web.Router do
  use Project2Web, :router

  import Project2Web.VendorAuth

  import Project2Web.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Project2Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_vendor
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Project2Web do
    pipe_through :browser

    live "/", HomeLive, :home
    live "/products/new", VendorProductLive, :new
    live "/products/:id/edit", EditProductLive, :edit
  end

  scope "/api", Project2Web do
    pipe_through :api
    resources "/transactions", TransactionController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Project2Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:project2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Project2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", Project2Web do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{Project2Web.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", Project2Web do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{Project2Web.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/cart", CartLive
      live "/user_account", UserAccountLive
      live "/checkout", CheckoutLive
      live "/wishlist", WishlistLive
    end
  end

  scope "/", Project2Web do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{Project2Web.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Authentication routes

  scope "/", Project2Web do
    pipe_through [:browser, :redirect_if_vendor_is_authenticated]

    live_session :redirect_if_vendor_is_authenticated,
      on_mount: [{Project2Web.VendorAuth, :redirect_if_vendor_is_authenticated}] do
      live "/vendors/register", VendorRegistrationLive, :new
      live "/vendors/log_in", VendorLoginLive, :new
      live "/vendors/reset_password", VendorForgotPasswordLive, :new
      live "/vendors/reset_password/:token", VendorResetPasswordLive, :edit
    end

    post "/vendors/log_in", VendorSessionController, :create
  end

  scope "/", Project2Web do
    pipe_through [:browser, :require_authenticated_vendor]

    live_session :require_authenticated_vendor,
      on_mount: [{Project2Web.VendorAuth, :ensure_authenticated}] do
      live "/vendors/settings", VendorSettingsLive, :edit
      live "/vendors/settings/confirm_email/:token", VendorSettingsLive, :confirm_email
      live "/vendors/products", VendorProductLive, :index
      live "/vendor_account", VendorAccountLive
    end
  end

  scope "/", Project2Web do
    pipe_through [:browser]

    delete "/vendors/log_out", VendorSessionController, :delete

    live_session :current_vendor,
      on_mount: [{Project2Web.VendorAuth, :mount_current_vendor}] do
      live "/vendors/confirm/:token", VendorConfirmationLive, :edit
      live "/vendors/confirm", VendorConfirmationInstructionsLive, :new
    end
  end
end
