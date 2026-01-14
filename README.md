# Billwatch

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploying

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Environment Variables

#### Development
All configuration is set in `config/dev.exs` - no environment variables needed.
- Invite code: `billwatch2026`

#### Test
All configuration is set in `config/test.exs` - no environment variables needed.
- Invite code: `test_invite_code`

#### Production
Required environment variables:

- `DATABASE_PATH` - Path to SQLite database file (e.g., `/etc/billwatch/billwatch.db`)
- `SECRET_KEY_BASE` - Secret key for signing/encrypting cookies (generate with `mix phx.gen.secret`)
- `INVITE_CODE` - Required code for user registration (use a strong random string)
- `PHX_HOST` - Hostname for the application (e.g., `billwatch.example.com`)

Optional environment variables:

- `PORT` - HTTP port (default: 4000)
- `POOL_SIZE` - Database connection pool size (default: 5)
- `PHX_SERVER` - Set to `true` to start Phoenix server (required for releases)

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
