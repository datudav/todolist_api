defmodule ToDoListAppWeb.Api.V1.TaskCommentView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.TaskCommentView

  def render("index.json", %{task_comments: task_comments}) do
    %{data: render_many(task_comments, TaskCommentView, "task_comment.json")}
  end

  def render("show.json", %{task_comment: task_comment}) do
    %{data: render_one(task_comment, TaskCommentView, "task_comment.json")}
  end

  def render("task_comment.json", %{task_comment: task_comment}) do
    %{
        task_comment_id: task_comment.task_comment_id,
        comments: task_comment.comments,
        creator_id: task_comment.creator_id,
        task_id: task_comment.task_id
      }
  end
end
