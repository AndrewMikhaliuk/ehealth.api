defmodule Core.LegalEntities.License do
  @moduledoc false

  use Ecto.Schema
  alias Core.LegalEntities.LegalEntity
  alias Ecto.UUID
  import Ecto.Changeset

  @fields_required ~w(
    is_active
    type
    issued_by
    issued_date
    active_from_date
    order_no
    inserted_by
    updated_by
  )a

  @fields_optional ~w(
    license_number
    issuer_status
    expiry_date
    what_licensed
  )a

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "licenses" do
    field(:is_active, :boolean, default: true)
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

  def changeset(%__MODULE__{} = entity, params) do
    entity
    |> cast(params, @fields_required ++ @fields_optional)
    |> validate_required(@fields_required)
  end
end
