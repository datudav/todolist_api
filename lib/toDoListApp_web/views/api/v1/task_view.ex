defmodule ToDoListAppWeb.Api.V1.TaskView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{
        task: %{
          task_id: task.task_id,
          title: task.title,
          description: task.description,
          rank: task.rank,
          list_id: task.list_id,
          assigned_to_id: task.assigned_to_id
        }
    }
  end
end
