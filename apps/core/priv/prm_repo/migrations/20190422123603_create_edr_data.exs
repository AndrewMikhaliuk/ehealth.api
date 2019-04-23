defmodule Core.PRMRepo.Migrations.CreateEdrData do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table("edr_data", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:edr_id, :integer)
      add(:name, :string)
      add(:short_name, :string)
      add(:public_name, :string)
      add(:state, :string)
      add(:legal_form, :string)
      add(:edrpou, :string)
      add(:kveds, :map)
      add(:registration_address, :map)
      add(:is_active, :boolean)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)

      timestamps(type: :utc_datetime)
    end
  end
end
