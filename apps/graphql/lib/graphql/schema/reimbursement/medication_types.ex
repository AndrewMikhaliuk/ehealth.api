defmodule GraphQL.Schema.MedicationTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import GraphQL.Resolvers.Helpers.Load, only: [load_by_args: 2]

  alias Absinthe.Relay.Node.ParseIDs
  alias Core.Medications.Medication
  alias GraphQL.Loaders.PRM
  alias GraphQL.Middleware.Filtering
  alias GraphQL.Resolvers.Medication, as: MedicationResolver

  object :medication_queries do
    connection field(:medications, node_type: :medication) do
      meta(:scope, ~w(medication:read))
      meta(:client_metadata, ~w(client_id client_type)a)
      meta(:allowed_clients, ~w(NHS))

      arg(:filter, :medication_filter)
      arg(:order_by, :medication_order_by, default_value: :inserted_at_desc)

      middleware(&transform_atc_code/2)

      middleware(Filtering,
        database_id: :equal,
        name: :like,
        is_active: :equal,
        form: :equal,
        code_atc: :contains,
        innm_dosages: [
          database_id: :equal,
          name: :like,
          is_active: :equal,
          form: :equal
        ],
        manufacturer: [name: :like]
      )

      resolve(&MedicationResolver.list_medications/2)
    end

    field(:medication, :medication) do
      meta(:scope, ~w(medication:read))
      meta(:client_metadata, ~w(client_id client_type)a)
      meta(:allowed_clients, ~w(NHS))

      arg(:id, non_null(:id))

      middleware(ParseIDs, id: :medication)

      resolve(load_by_args(PRM, Medication))
    end
  end

  input_object :medication_filter do
    field(:database_id, :uuid)
    field(:name, :string)
    field(:is_active, :boolean)
    field(:form, :string)
    field(:atc_code, :string)
    field(:innm_dosages, :innm_dosage_filter)
    field(:manufacturer, :manufacturer_filter)
  end

  input_object :manufacturer_filter do
    field(:name, :string)
  end

  enum :medication_order_by do
    value(:inserted_at_asc)
    value(:inserted_at_desc)
    value(:name_asc)
    value(:name_desc)
  end

  connection node_type: :medication do
    field :nodes, list_of(:medication) do
      resolve(fn _, %{source: conn} -> {:ok, Enum.map(conn.edges, & &1.node)} end)
    end

    edge(do: nil)
  end

  object :medication_mutations do
    payload field(:create_medication) do
      meta(:scope, ~w(medication:write))
      meta(:client_metadata, ~w(consumer_id client_type)a)
      meta(:allowed_clients, ~w(NHS))

      input do
        field(:atc_codes, non_null(list_of(:string)))
        field(:certificate, non_null(:string))
        field(:certificate_expired_at, non_null(:date))
        field(:container, non_null(:container_input))
        field(:daily_dosage, :float)
        field(:form, non_null(:string))
        field(:ingredients, non_null(list_of(:medication_ingredient_input)))
        field(:manufacturer, :manufacturer_input)
        field(:name, non_null(:string))
        field(:package_min_qty, :integer)
        field(:package_qty, non_null(:integer))
      end

      output do
        field(:medication, :medication)
      end

      resolve(&MedicationResolver.create/2)
    end

    payload field(:deactivate_medication) do
      meta(:scope, ~w(medication:write))
      meta(:client_metadata, ~w(consumer_id client_type)a)
      meta(:allowed_clients, ~w(NHS))

      input do
        field(:id, non_null(:id))
      end

      output do
        field(:medication, :medication)
      end

      middleware(ParseIDs, id: :medication)
      resolve(&MedicationResolver.deactivate/2)
    end
  end

  input_object :container_input do
    # Dictionary: MEDICATION_UNIT
    field(:numerator_unit, non_null(:string))
    field(:numerator_value, non_null(:integer))
    # Dictionary: MEDICATION_UNIT
    field(:denumerator_unit, non_null(:string))
    field(:denumerator_value, non_null(:integer))
  end

  input_object :medication_ingredient_input do
    field(:dosage, non_null(:container_input))
    field(:is_primary, non_null(:boolean))
    field(:innm_dosage_id, non_null(:id))
  end

  input_object :manufacturer_input do
    field(:name, non_null(:string))
    field(:country, non_null(:string))
  end

  node object(:medication) do
    field(:database_id, non_null(:uuid))
    field(:atc_codes, non_null(list_of(:string)), resolve: fn _, res -> {:ok, res.source.code_atc} end)
    field(:certificate, :string)
    field(:certificate_expired_at, :date)
    field(:container, non_null(:container))
    field(:daily_dosage, :float)
    # Dictionary: MEDICATION_FORM
    field(:form, :string)
    field(:ingredients, non_null(list_of(:medication_ingredient)), resolve: dataloader(PRM))
    field(:is_active, non_null(:boolean))
    field(:manufacturer, :manufacturer)
    field(:name, non_null(:string))
    field(:package_min_qty, :integer)
    field(:package_qty, :integer)
    field(:type, :medication_type)
    field(:inserted_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
  end

  object :manufacturer do
    field(:name, non_null(:string))
    field(:country, non_null(:string))
  end

  object :container do
    # Dictionary: MEDICATION_UNIT
    field(:numerator_unit, non_null(:string))
    field(:numerator_value, non_null(:string))
    # Dictionary: MEDICATION_UNIT
    field(:denumerator_unit, non_null(:string))
    field(:denumerator_value, non_null(:string))
  end

  input_object :create_dosage_input do
    # Dictionary: MEDICATION_UNIT
    field(:numerator_unit, non_null(:string))
    field(:numerator_value, non_null(:integer))
    # Dictionary: MEDICATION_UNIT
    field(:denumerator_unit, non_null(:string))
    field(:denumerator_value, non_null(:integer))
  end

  object :medication_ingredient do
    interface(:ingredient)

    field(:dosage, non_null(:dosage))
    field(:is_primary, non_null(:boolean))
    field(:innm_dosage, non_null(:innm_dosage), resolve: dataloader(PRM))
  end

  enum :medication_type do
    value(:brand, as: "BRAND")
    value(:innm_dosage, as: "INNM_DOSAGE")
  end

  defp transform_atc_code(%{arguments: %{filter: %{atc_code: code} = filter} = arguments} = resolution, _) do
    updated_filter = filter |> Map.delete(:atc_code) |> Map.put(:code_atc, [code])

    %{resolution | arguments: %{arguments | filter: updated_filter}}
  end

  defp transform_atc_code(resolution, _), do: resolution
end
