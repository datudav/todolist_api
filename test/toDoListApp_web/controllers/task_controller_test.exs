defmodule ToDoListAppWeb.TaskControllerTest do
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
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => _,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_v1_task_path(conn, :index, params: %{list_id: list_id}))

      assert %{
        "task_id" => _,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      assert Enum.count(json_response(conn, 200)["data"]) === 1
    end

    test "renders empty data when passed list_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_task_path(conn, :index, params: %{list_id: Ecto.UUID.generate}))
      assert response(conn, 200)
      assert Enum.count(json_response(conn, 200)["data"]) === 0
    end
  end

  describe "show" do
    setup [:create_user]

    test "render task", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_v1_task_path(conn, :show, task_id))

      assert %{
        "task_id" => _,
        "list_id" => _,
        "assigned_to_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 200)["data"]
    end

    test "render errors when passed task_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_task_path(conn, :show, Ecto.UUID.generate))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end

  describe "create" do
    setup [:create_user]

    test "render created task", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => _,
        "list_id" => _,
        "assigned_to_id" => nil,
        "title" => "Task 1",
        "description" => "This is the first task."
      } = json_response(conn, 201)["data"]
    end

    test "render errors when creating task with incomplete details", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: nil, description: nil, list_id: list_id})

      assert %{"detail" => _} = json_response(conn, 422)["errors"]
    end
  end

  describe "delete" do
    setup [:create_user]

    test "no response on delete task", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => nil,
        "title" => "Task 1",
        "description" => "This is the first task."
      } = json_response(conn, 201)["data"]

      conn = delete(conn, Routes.api_v1_task_path(conn, :delete, task_id))
      assert response(conn, 204)

      conn = get(conn, Routes.api_v1_task_path(conn, :show, task_id))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end

    test "render errors when task_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = delete(conn, Routes.api_v1_task_path(conn, :delete, Ecto.UUID.generate))
      assert response(conn, 404)
    end
  end

  describe "update" do
    setup [:create_user]

    test "render task", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => nil,
        "title" => "Task 1",
        "description" => "This is the first task."
      } = json_response(conn, 201)["data"]

      conn = patch(conn, Routes.api_v1_task_path(conn, :update, task_id), task: %{"title" => "Task 1 updated title", "description" => "Updated description", "assigned_to_id" => owner_id})
      assert %{
        "task_id" => _,
        "list_id" => _,
        "assigned_to_id" => assigned_to_id,
        "title" => "Task 1 updated title",
        "description" => "Updated description"
      } = json_response(conn, 200)["data"]

      assert assigned_to_id === owner_id
    end

    test "render errors when request is missing required fields", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = post(conn, Routes.api_v1_list_path(conn, :create), list: %{title: "List 1", description: "This is the first list.", board_id: board_id, creator_id: owner_id})

      assert %{
        "list_id" => list_id,
        "board_id" => _,
        "creator_id" => _,
        "title" => _,
        "description" => _
      } = json_response(conn, 201)["data"]

      conn = post(conn, Routes.api_v1_task_path(conn, :create), task: %{title: "Task 1", description: "This is the first task.", list_id: list_id})

      assert %{
        "task_id" => task_id,
        "list_id" => _,
        "assigned_to_id" => nil,
        "title" => "Task 1",
        "description" => "This is the first task."
      } = json_response(conn, 201)["data"]

      conn = patch(conn, Routes.api_v1_task_path(conn, :update, task_id), task: %{"title" => nil, "description" => nil})

      assert %{
        "detail" => "Title is required."
      } = json_response(conn, 422)["errors"]
    end
  end
end
