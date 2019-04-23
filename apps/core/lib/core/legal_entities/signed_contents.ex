defmodule Core.LegalEntities.SignedContent do
  @moduledoc false

  use Ecto.Schema
  alias Core.LegalEntities.LegalEntity

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "legal_entity_signed_contents" do
    field(:filename, :string)
    belongs_to(:legal_entity, LegalEntity)

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
