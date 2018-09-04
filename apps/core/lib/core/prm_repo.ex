defmodule Core.PRMRepo do
  @moduledoc false

  use Ecto.Repo, otp_app: :core
  use Scrivener, max_page_size: 500, page_size: 50
  use EctoTrail
end