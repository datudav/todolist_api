defmodule ToDoListAppWeb.TaskCommentControllerTest do
  use ToDoListAppWeb.ConnCase

  alias ToDoListApp.Account

  @create_user_attrs %{
    "email" => "some@email.com",
    "password" => "some password"
  }

  @create_user_attrs2 %{
    "email" => "some2@email.com",
    "password" => "some2 password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def fixture(:user) do
    {:ok, user} = Account.register_user(@create_user_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

  describe "index" do
    setup [:create_user]

    test "list tasks", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => _,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]

      conn = get(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :index, board_id, list_id, task_id))

      %{
        "task_id" => _,
        "task_comment_id" => _,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = Enum.at(json_response(conn, 200)["data"], 0)["task_comment"]
    end

    test "render errors when passed task_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :index, Ecto.UUID.generate, Ecto.UUID.generate, Ecto.UUID.generate))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end

  describe "show" do
    setup [:create_user]

    test "render task comment", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => task_comment_id,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]

      conn = get(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :show, board_id, list_id, task_id, task_comment_id))

      assert %{
        "task_id" => _,
        "task_comment_id" => _,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 200)["data"]["task_comment"]
    end

    test "render errors when passed task_comment_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :show, Ecto.UUID.generate, Ecto.UUID.generate, Ecto.UUID.generate, Ecto.UUID.generate))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end

  describe "create" do
    setup [:create_user]

    test "render created task comment", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => _,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]
    end

    test "render errors when creating task comment with incomplete details", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: nil, task_id: task_id, creator_id: owner_id})

      assert %{"detail" => _} = json_response(conn, 422)["errors"]
    end
  end

  describe "delete" do
    setup [:create_user]

    test "no response on delete task comment", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => task_comment_id,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]

      conn = delete(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :delete, board_id, list_id, task_id, task_comment_id))
      assert response(conn, 204)

      conn = get(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :show, board_id, list_id, task_id, task_comment_id))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end

    test "render errors when task_comment_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => _
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = delete(conn, Routes.api_v1_board_list_task_path(conn, :delete, Ecto.UUID.generate, Ecto.UUID.generate, Ecto.UUID.generate))
      assert response(conn, 404)
    end
  end

  describe "update" do
    setup [:create_user]

    test "render task comment", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => task_comment_id,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]

      conn = patch(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :update, board_id, list_id, task_id,task_comment_id), task_comment: %{"comments" => "Task comment updated"})

      assert %{
        "task_id" => _,
        "task_comment_id" => _,
        "creator_id" => _,
        "comments" =>  "Task comment updated"
      } = json_response(conn, 200)["data"]["task_comment"]
    end

    test "render errors when request is missing required fields", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_list_path(conn, :create, board_id), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["list"]

      conn = post(conn, Routes.api_v1_board_list_task_path(conn, :create, board_id, list_id), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]["task"]

      conn = post(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :create, board_id, list_id, task_id), task_comment: %{comments: "Task comment 1", task_id: task_id, creator_id: owner_id})

      %{
        "task_id" => _,
        "task_comment_id" => task_comment_id,
        "creator_id" => _,
        "comments" => "Task comment 1"
      } = json_response(conn, 201)["data"]["task_comment"]

      conn = patch(conn, Routes.api_v1_board_list_task_task_comment_path(conn, :update, board_id, list_id, task_id, task_comment_id), task_comment: %{"comments" => nil})

      assert %{
        "detail" => "Comments is required."
      } = json_response(conn, 422)["errors"]
    end
  end
end
