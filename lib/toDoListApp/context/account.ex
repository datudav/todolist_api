defmodule ToDoListApp.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias ToDoListApp.Repo

  alias ToDoListApp.Account.User
  alias ToDoListApp.Account.Permission
  alias ToDoListApp.Account.BoardPermission

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
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
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
    user
    |> User.changeset(attrs)
    |> Repo.update()
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

  def list_board_permission(board_id) do
    Repo.all(from b in BoardPermission,
            where: b.board_id == ^board_id)
  end

  def create_board_permission(attrs \\ %{}) do
    %BoardPermission{}
    |> BoardPermission.changeset(attrs)
    |> Repo.insert()
  end

  def get_board_permission(board_permission_id), do: Repo.get!(BoardPermission, board_permission_id)

  def update_board_permission(%BoardPermission{} = board_permission, attrs) do
    board_permission
    |> BoardPermission.changeset(attrs)
    |> Repo.update()
  end

  def delete_board_permission(%BoardPermission{} = board_permission) do
    Repo.delete(board_permission)
  end

  def check_user_permission(board_id, user_id) do
    case board_permission = Repo.get_by(BoardPermission, board_id: board_id, user_id: user_id) do
      nil -> {:error, "The user does not have permission to perform the operation."}
      _ -> {:ok, board_permission}
    end
  end
end
