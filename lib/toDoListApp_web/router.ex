defmodule ToDoListAppWeb.Router do
  use ToDoListAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_auth do
    plug :ensure_authenticated
  end

  scope "/api", ToDoListAppWeb, as: :api do
    pipe_through :api

    scope "/v1", Api.V1, as: :v1 do
      post "/users/sign_in", UserController, :sign_in
    end
  end

  scope "/api", ToDoListAppWeb, as: :api do
    pipe_through [:api, :api_auth]

    scope "/v1", Api.V1, as: :v1 do
      resources "/users", UserController, except: [:new, :edit]
      resources "/board", BoardController, only: [:index] do
        resources "/board_permissions", BoardPermissionController, except: [:edit, :update]
        resources "/lists", ListController, except: [:new, :edit] do
          resources "/tasks", TaskController, except: [:new, :edit] do
            resources "/task_comments", TaskCommentController, except: [:new, :edit]
          end
        end
      end
    end
  end

  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(ToDoListAppWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end

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
      live_dashboard "/dashboard", metrics: ToDoListAppWeb.Telemetry
    end
  end
end
