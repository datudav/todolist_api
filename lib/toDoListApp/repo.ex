defmodule ToDoListApp.Repo do
  use Ecto.Repo,
    otp_app: :toDoListApp,
    adapter: Ecto.Adapters.Postgres
end
