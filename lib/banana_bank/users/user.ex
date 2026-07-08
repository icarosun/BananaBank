defmodule BananaBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias BananaBank.Accounts.Account

  @required_params_create [:name, :password, :email, :cep]
  @required_params_update [:name, :email, :cep]

  schema "users" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    field :cep, :string
    has_one :account, Account

    timestamps()
  end

  # def changeset(user \\ %__MODULE__{}, params)

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params_create)
    |> do_validateions(@required_params_create)
    |> add_password_hash()
  end

  def changeset(user, params) do
    user
    |> cast(params, @required_params_create)
    |> do_validateions(@required_params_update)
    |> add_password_hash()
  end

  defp do_validateions(changeset, fields) do
    changeset
    |> validate_required(fields)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:cep, is: 8)
    |> validate_length(:password, is: 6)
  end

  defp add_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    hash = Argon2.hash_pwd_salt(password)

    change(changeset, %{password_hash: hash})
  end

  defp add_password_hash(changeset), do: changeset
end
