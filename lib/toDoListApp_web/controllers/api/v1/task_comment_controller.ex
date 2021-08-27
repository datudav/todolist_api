defmodule ToDoListAppWeb.Api.V1.TaskCommentController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.TaskContext
  alias ToDoListApp.TaskContext.TaskComment

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"task_id" => task_id}) do
    task_comments = TaskContext.list_task_comments(task_id)
    render(conn, "index.json", tasks: task_comments)
  end

  def create(conn, %{"task_comment" => task_comment_params}) do
    with {:ok, %TaskComment{} = task_comment} <- TaskContext.create_task_comment(task_comment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.task_comment_path(conn, :show, task_comment))
      |> render("show.json", task_comment: task_comment)
    end
  end

  def show(conn, %{"task_comment_id" => task_comment_id}) do
    with {:ok, task_comment} <- TaskContext.get_task_comment!(task_comment_id) do
      render(conn, "show.json", task_comment: task_comment)
    else
      err -> err
    end
  end

  def update(conn, %{"task_comment_id" => task_comment_id, "task_comment" => task_comment_params}) do
    with {:ok, task_comment} <- TaskContext.get_task_comment!(task_comment_id),
        {:ok, %TaskComment{} = task_comment} <- TaskContext.update_task_comment(task_comment, task_comment_params) do
      render(conn, "show.json", task_comment: task_comment)
    else
      err -> err
    end
  end

  def delete(conn, %{"task_comment_id" => task_comment_id}) do
    with {:ok, task_comment} <- TaskContext.get_task_comment!(task_comment_id),
        {:ok, %TaskComment{}} <- TaskContext.delete_task_comment(task_comment) do
      send_resp(conn, :no_content, "")
    else
      err -> err
    end
  end
end
