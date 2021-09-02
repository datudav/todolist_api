defmodule ToDoListAppWeb.Api.V1.BoardPermissionView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.BoardPermissionView

  def render("index.json", %{board_permissions: board_permissions}) do
    %{data: render_many(board_permissions, BoardPermissionView, "board_permission.json")}
  end

  def render("show.json",%{board_permission: board_permission}) do
    %{data: render_one(board_permission, BoardPermissionView, "board_permission.json")}
  end

  def render("board_permission.json", %{board_permission: board_permission}) do
    %{
        board_permission_id: board_permission.board_permission_id,
        board_id: board_permission.board_id,
        permission_type: board_permission.permission_type,
        user_id: board_permission.user_id
    }
  end
end
