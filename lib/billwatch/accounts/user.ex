defmodule Billwatch.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true
    field :invite_code, :string, virtual: true

    has_one :account_user, Billwatch.Accounts.AccountUser
    has_one :account, through: [:account_user, :account]
    has_one :role, through: [:account_user, :role]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  A user changeset for changing the password.

  It is important to validate the length of the password, as long passwords may
  be very expensive to hash for certain algorithms.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password, :current_password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password()
    |> validate_current_password(opts)
  end

  @doc """
  A user changeset for registration.

  It requires email, password, and a valid invite code to be set.
  """
  def registration_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :invite_code])
    |> validate_email()
    |> validate_password()
    |> validate_invite_code()
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Billwatch.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Billwatch.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 10, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> hash_password()
  end

  defp validate_current_password(changeset, opts) do
    # Skip validation entirely for password reset
    if Keyword.get(opts, :skip_current_password, false) do
      changeset
    else
      current_password = get_change(changeset, :current_password)
      changeset = validate_required(changeset, [:current_password])

      if Keyword.get(opts, :validate_current_password, false) && not valid_password?(changeset.data, current_password) do
        add_error(changeset, :current_password, "is not valid")
      else
        changeset
      end
    end
  end

  defp validate_invite_code(changeset) do
    required_code = Application.fetch_env!(:billwatch, :invite_code)
    provided_code = get_change(changeset, :invite_code) || ""

    # Constant-time comparison to prevent timing attacks
    if Plug.Crypto.secure_compare(provided_code, required_code) do
      changeset
    else
      add_error(changeset, :invite_code, "is invalid")
    end
  end
end
