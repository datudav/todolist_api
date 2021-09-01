defmodule ToDoListAppWeb.Api.V1.TaskCommentController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.TaskContext
  alias ToDoListApp.TaskContext.TaskComment
  alias ToDoListApp.ListContext
  alias ToDoListApp.ListContext.List

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"task_id" => task_id}) do
    case TaskContext.get_task!(task_id) do
      {:ok, _task} ->
        with {:ok, task_comments} <- {:ok, TaskContext.list_task_comments(task_id)} do
          conn
          |> put_status(:ok)
          |> render("index.json", task_comments: task_comments)
        else
          err ->
          conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: err)
        end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def create(conn, %{"task_id" => task_id, "task_comment" => task_comment_params}) do
    case TaskContext.get_task!(task_id) do
      {:ok, task} ->
        with {:ok, %TaskComment{} = task_comment} <- TaskContext.create_task_comment(task_comment_params),
            {:ok, %List{} = list} <- ListContext.get_list!(task.list_id) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.api_v1_board_list_task_task_comment_path(conn, :show, list.board_id, list.list_id, task.task_id, task_comment.task_comment_id))
          |> render("show.json", task_comment: task_comment)
        else
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

  def show(conn, %{"id" => task_comment_id}) do
    case TaskContext.get_task_comment!(task_comment_id) do
      {:ok, task_comment} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.TaskCommentView)
        |> render("show.json", task_comment: task_comment)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def update(conn, %{"id" => task_comment_id, "task_comment" => task_comment_params}) do
    with {:ok, task_comment} <- TaskContext.get_task_comment!(task_comment_id),
        {:ok, %TaskComment{} = task_comment} <- TaskContext.update_task_comment(task_comment, task_comment_params) do
      render(conn, "show.json", task_comment: task_comment)
    else
      err -> err
    end

    case TaskContext.get_task_comment!(task_comment_id) do
      {:ok, task_comment} ->
        case TaskContext.update_task_comment(task_comment, task_comment_params) do
          {:ok, task_comment} ->
            conn
            |> put_status(:ok)
            |> put_view(ToDoListAppWeb.Api.V1.TaskCommentView)
            |> render("show.json", task_comment: task_comment)
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

  def delete(conn, %{"id" => task_comment_id}) do
    case TaskContext.get_task_comment!(task_comment_id) do
      {:ok, task_comment} ->
        case TaskContext.delete_task_comment(task_comment) do
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
end
