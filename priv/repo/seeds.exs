alias Billwatch.Accounts
alias Billwatch.Accounts.User
alias Billwatch.Repo

invite_code = Application.fetch_env!(:billwatch, :invite_code)
email = "user@example.com"

case Accounts.get_user_by_email(email) do
  nil ->
    IO.puts("Creating user: #{email}")

    # Register the user with a default password
    {:ok, user} =
      Accounts.register_user(%{
        email: email,
        password: "Password123!",
        invite_code: invite_code
      })

    # Confirm the user
    user
    |> User.confirm_changeset()
    |> Repo.update!()

    IO.puts("User #{email} created and confirmed successfully")

  %User{confirmed_at: nil} = user ->
    IO.puts("User #{email} exists but is not confirmed. Confirming now...")

    user
    |> User.confirm_changeset()
    |> Repo.update!()

    IO.puts("User #{email} confirmed successfully")

  %User{} ->
    IO.puts("User #{email} already exists and is confirmed")
end
