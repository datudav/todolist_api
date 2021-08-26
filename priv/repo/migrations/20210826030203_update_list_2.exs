defmodule ToDoListApp.Repo.Migrations.UpdateList2 do
  use Ecto.Migration

  def change do
    alter table(:list) do
      modify :creator_id, :uuid, null: false
    end
  end
end
