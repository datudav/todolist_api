defmodule ToDoListApp.Repo.Migrations.UpdateUsers3 do
  use Ecto.Migration

  def change do
    rename table(:users), :id, to: :user_id
  end
end
