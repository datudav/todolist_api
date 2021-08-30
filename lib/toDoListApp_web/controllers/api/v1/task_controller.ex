defmodule ToDoListAppWeb.Api.V1.TaskController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.TaskContext
  alias ToDoListApp.TaskContext.Task

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"list_id" => list_id}) do
    tasks = TaskContext.list_tasks(list_id)
    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- TaskContext.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_board_list_task_path(:show, task.board_id, task.list_id, task.task_id))
      |> render("show.json", task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = TaskContext.get_task!(id)
    render(conn, "show.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = TaskContext.get_task!(id)

    with {:ok, %Task{} = task} <- TaskContext.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = TaskContext.get_task!(id)

    with {:ok, %Task{}} <- TaskContext.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
