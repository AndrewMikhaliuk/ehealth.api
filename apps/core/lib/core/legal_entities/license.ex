defmodule Core.LegalEntities.License do
  @moduledoc false

  use Ecto.Schema
  alias Core.LegalEntities.LegalEntity
  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "licenses" do
    field(:is_active, :boolean)
    field(:license_number, :string)
    field(:type, :string)
    field(:issued_by, :string)
    field(:issued_date, :date)
    field(:issuer_status, :string)
    field(:expiry_date, :date)
    field(:active_from_date, :date)
    field(:what_licensed, :string)
    field(:order_no, :string)
    field(:inserted_by, UUID)
    field(:updated_by, UUID)

    has_many(:legal_entities, LegalEntity)

    timestamps(type: :utc_datetime)
  end
end
