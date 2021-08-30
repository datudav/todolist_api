defmodule ToDoListAppWeb.Api.V1.UserController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.Account

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.json", users: users)
  end

  def register(conn, %{"user" => user_params}) do
    case Account.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_view(ToDoListAppWeb.Api.V1.UserView)
        |> render("sign_in.json", user: user)
      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("422.json", message: message)
    end
  end

  def show(conn, %{"id" => user_id}) do
    case Account.get_user!(user_id) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.UserView)
        |> render("show.json", user: user)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def update(conn, %{"id" => user_id, "user" => user_params}) do
    case Account.get_user!(user_id) do
      {:ok, user} ->
        case Account.update_user(user, user_params) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> put_view(ToDoListAppWeb.Api.V1.UserView)
            |> render("show.json", user: user)
          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: message)
      end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Account.get_user!(id) do
      {:ok, user} ->
        case Account.delete_user(user) do
          {:ok, _} ->
            conn
            |> put_status(:no_content)
            |> send_resp(204, "")
          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: message)
        end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case ToDoListApp.Account.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.user_id)
        |> configure_session(renew: true)
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.UserView)
        |> render("sign_in.json", user: user)
      {:error, message} ->
        conn
        |> delete_session(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end
end
