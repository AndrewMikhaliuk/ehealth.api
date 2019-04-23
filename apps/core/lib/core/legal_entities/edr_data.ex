defmodule Core.LegalEntities.EdrData do
  @moduledoc false

  use Ecto.Schema
  alias Core.LegalEntities.LegalEntity
  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "edr_data" do
    field(:edr_id, :integer)
    field(:name, :string)
    field(:short_name, :string)
    field(:public_name, :string)
    field(:state, :string)
    field(:legal_form, :string)
    field(:edrpou, :string)
    field(:kveds, :map)
    field(:registration_address, :map)
    field(:is_active, :boolean)
    field(:inserted_by, UUID)
    field(:updated_by, UUID)

    has_one(:legal_entity, LegalEntity, foreign_key: :edr_data_id)

    timestamps(type: :utc_datetime)
  end
end
