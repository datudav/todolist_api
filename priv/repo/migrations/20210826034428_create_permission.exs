defmodule ToDoListApp.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def change do
    create table(:permission, primary_key: false) do
      add :permission_id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :description, :text, null: false

      timestamps()
    end

    execute("INSERT INTO permission (description, inserted_at, updated_at)
      VALUES ('Manage', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
      ('Write', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
      ('Read', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ")
  end
end
