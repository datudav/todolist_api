defmodule ToDoListAppWeb.Api.V1.ListView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.ListView

  def render("index.json", %{lists: lists}) do
    %{data: render_many(lists, ListView, "list.json")}
  end

  def render("show.json", %{list: list}) do
    %{data: render_one(list, ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    %{id: list.list_id,
      title: list.title,
      description: list.description,
      board_id: list.board_id}
  end
end
