defmodule ToDoListAppWeb.Api.V1.ListController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.ListContext
  alias ToDoListApp.ListContext.List

  def index(conn, %{"board_id" => board_id}) do
    lists = ListContext.list_lists(board_id)
    render(conn, "index.json", lists: lists)
  end

  def show(conn, %{"list_id" => list_id}) do
    with {:ok, list} <- ListContext.get_list(list_id)
    do
      render(conn, "show.json", list: list)
    else
      err -> err
    end
  end

  def create(conn, %{"list" => list_params}) do
    with {:ok, %List{} = list} <- ListContext.create_list(list_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_board_list_path(conn, :show, list))
      |> render("show.json", list: list)
    end
  end

  def update(conn, %{"list_id" => list_id, "list" => list_params}) do
    with {:ok, list} <- ListContext.get_list(list_id),
        {:ok, %List{} = list} <- ListContext.update_list(list, list_params) do
      render(conn, "show.json", list: list)
    else
      err -> err
    end
  end

  def delete(conn, %{"list_id" => list_id}) do
    with {:ok, list} <- ListContext.get_list(list_id),
        {:ok, %List{}} <- ListContext.delete_list(list)
    do
      send_resp(conn, :no_content, "")
    else
      err -> err
    end
  end

end
