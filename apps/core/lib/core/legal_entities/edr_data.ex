defmodule Core.LegalEntities.EdrData do
  @moduledoc false

  use Ecto.Schema

  alias Core.Divisions.Division
  alias Core.Employees.Employee
  alias Core.LegalEntities.MedicalServiceProvider
  alias Core.LegalEntities.RelatedLegalEntity
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

    belongs_to(:legal_entity, LegalEntity, type: UUID)

    timestamps(type: :utc_datetime)
  end
end
