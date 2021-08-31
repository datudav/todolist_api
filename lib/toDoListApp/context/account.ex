defmodule ToDoListApp.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias ToDoListApp.Repo

  alias ToDoListApp.Account.User
  alias ToDoListApp.Account.Permission
  alias ToDoListApp.BoardContext
  alias ToDoListApp.BoardContext.Board
  alias ToDoListApp.BoardContext.BoardPermission

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(user_id) do
    case user = Repo.get_by(User, user_id: user_id) do
      nil -> {:error, "The user does not exist"}
      _ -> {:ok, user}
    end
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    if get_user_by_email(attrs["email"]) == nil do
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()
    else
      {:error, "The email is already taken."}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    with {:ok, "Validation passed"} <- validate_user(attrs) do
      if get_user_by_email(attrs["email"]) == nil do
        user
        |> User.changeset(attrs)
        |> Repo.update()
      else
        {:error, "The email is already taken."}
      end
    else
      err -> err
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def authenticate_user(email, password) do
    query = from(u in User, where: u.email == ^email)
    query
    |> Repo.one()
    |> verify_password(password)
  end

  def verify_password(user, password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Invalid credentials"}
    end
  end

  def register_user(user_params) do
    with {:ok, "Validation passed"} <- validate_user(user_params),
      {:ok, %User{} = user} <- create_user(user_params),
      {:ok, %Board{} = board} <-
        BoardContext.create_board(%{title: "User Board",
        description: "Registered user's board",
        owner_id: user.user_id}),
      {:ok, %BoardPermission{}} <-
        BoardContext.create_board_permission(%{user_id: user.user_id,
        board_id: board.board_id,
        permission_type: :manage}) do
      {:ok, user}
    else
      err -> err
    end
  end

  defp validate_user(user_params) do
    case user_params do
      %{"email" => nil} -> {:error, "Email is required."}
      %{"email" => ""} -> {:error, "Email is required."}
      %{"password" => nil} -> {:error, "Password is required"}
      %{"password" => ""} -> {:error, "Password is required"}
      _ -> {:ok, "Validation passed"}
    end
  end

  def list_permission do
    Repo.all(Permission)
  end

  def get_permission(id), do: Repo.get!(Permission, id)

  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end
end
