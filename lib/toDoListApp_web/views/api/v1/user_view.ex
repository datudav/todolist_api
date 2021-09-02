defmodule ToDoListAppWeb.Api.V1.UserView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      user_id: user.user_id,
      email: user.email
    }
  end

  def render("sign_in.json", %{user: user}) do
    %{
      data: %{
          user_id: user.user_id,
          email: user.email
      }
    }
  end
end
