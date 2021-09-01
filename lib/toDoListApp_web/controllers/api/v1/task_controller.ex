defmodule ToDoListAppWeb.Api.V1.TaskController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.TaskContext
  alias ToDoListApp.TaskContext.Task
  alias ToDoListApp.ListContext

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"list_id" => list_id}) do
    case ListContext.get_list!(list_id) do
      {:ok, _list} ->
        with {:ok, tasks} <- {:ok, TaskContext.list_tasks(list_id)} do
          conn
          |> put_status(:ok)
          |> render("index.json", tasks: tasks)
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

  def create(conn, %{"list_id" => list_id, "task" => task_params}) do
     case ListContext.get_list!(list_id) do
      {:ok, list} ->
        with {:ok, %Task{} = task} <- TaskContext.create_task(task_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.api_v1_board_list_task_path(conn, :show, list.board_id, list.list_id, task.task_id))
          |> render("show.json", task: task)
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

  def show(conn, %{"id" => task_id}) do
    case TaskContext.get_task!(task_id) do
      {:ok, task} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.TaskView)
        |> render("show.json", task: task)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def update(conn, %{"id" => task_id, "task" => task_params}) do
    case TaskContext.get_task!(task_id) do
      {:ok, task} ->
        case TaskContext.update_task(task, task_params) do
          {:ok, task} ->
            conn
            |> put_status(:ok)
            |> put_view(ToDoListAppWeb.Api.V1.TaskView)
            |> render("show.json", task: task)
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

  def delete(conn, %{"id" => task_id}) do
    case TaskContext.get_task!(task_id) do
      {:ok, task} ->
        case TaskContext.delete_task(task) do
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
