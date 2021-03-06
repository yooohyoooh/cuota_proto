defmodule CuotaProtoWeb.Router do
  use CuotaProtoWeb, :router

  import CuotaProtoWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CuotaProtoWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CuotaProtoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CuotaProtoWeb.Telemetry


    end
  end

  ## Authentication routes

  scope "/", CuotaProtoWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", CuotaProtoWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    put "/users/settings/delete", UserSettingsController, :delete
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    resources "/matters", MatterController
    post "/", PageController, :add_matter

    get "/to", PageController, :to

    delete "/delete", PageController, :delete
    delete "/all_delete", PageController, :all_delete

    post "/path", PageController, :path

    resources "/fileuploads", FileUploadController, only: [:index, :create, :new]
    get "/fileuploads/set", FileUploadController, :set
    get "/fileuploads/delete", FileUploadController, :delete
    post "/fileuploads/preview", FileUploadController, :preview
    get "/fileuploads/cancel_preview", FileUploadController, :cancel_preview
    get "/fileuploads/all", FileUploadController, :all
    get "/fileuploads/receive", FileUploadController, :receive

    resources "/messages", MessageController
  end

  scope "/", CuotaProtoWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
