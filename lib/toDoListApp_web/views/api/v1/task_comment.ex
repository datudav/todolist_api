defmodule ToDoListAppWeb.Api.V1.TaskCommentView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.TaskCommentView

  def render("index.json", %{comments: comments}) do
    %{data: render_many(comments, TaskCommentView, "task_comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{data: render_one(comment, TaskCommentView, "task_comment.json")}
  end

  def render("task_comment.json", %{comment: comment}) do
    %{id: comment.comment_id,
      comments: comment.comments,
      user_id: comment.user_id,
      task_id: comment.task_id}
  end

end
