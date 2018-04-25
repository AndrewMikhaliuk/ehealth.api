defmodule EHealth.Persons do
  @moduledoc false

  import EHealth.Utils.Connection, only: [get_consumer_id: 1]

  alias EHealth.API.Mithril
  alias EHealth.API.Signature
  alias EHealth.Persons.Person
  alias EHealth.Persons.Search
  alias EHealth.Persons.Signed
  alias EHealth.Validators.Addresses
  alias EHealth.Validators.JsonSchema
  alias EHealth.Persons.Validator, as: PersonValidator

  @mpi_api Application.get_env(:ehealth, :api_resolvers)[:mpi]
  @addresses_types ~w(REGISTRATION RESIDENCE)

  def search(params, headers \\ []) do
    with %Ecto.Changeset{valid?: true, changes: changes} <- Search.changeset(params),
         search_params <- Map.put(changes, "status", "active"),
         {:ok, %{"data" => persons, "paging" => %{"total_pages" => 1}}} <- @mpi_api.search(search_params, headers) do
      {:ok, persons, changes}
    else
      {:ok, %{"paging" => %{"total_pages" => _}} = paging} -> {:error, paging}
      error -> error
    end
  end

  def update(id, params, headers) do
    user_id = get_consumer_id(headers)

    with {:ok, %{"data" => user}} <- Mithril.get_user_by_id(user_id, headers),
         :ok <- check_user_person_id(user, id),
         %Ecto.Changeset{valid?: true, changes: changes} <- Signed.changeset(params),
         {:ok, %{"data" => %{"content" => content, "signer" => signer}}} <-
           Signature.decode_and_validate(changes.signed_content, "base64", headers),
         {:ok, %{"data" => person}} <- @mpi_api.person(user["person_id"], headers),
         :ok <- validate_tax_id(user["tax_id"], person["tax_id"], content, signer),
         :ok <- JsonSchema.validate(:person, content),
         :ok <- PersonValidator.validate_addresses_types(content["addresses"], @addresses_types),
         {:ok, _} <- Addresses.validate(content["addresses"]),
         :ok <- PersonValidator.validate_birth_certificate_number(content),
         %Ecto.Changeset{valid?: true, changes: changes} <- Person.changeset(content),
         :ok <-
           PersonValidator.validate_authentication_method_phone_number(
             Map.get(changes, :authentication_methods),
             headers
           ),
         {:ok, %{"data" => data}} <- @mpi_api.update_person(id, changes, headers) do
      {:ok, data}
    end
  end

  def get_person(headers) do
    user_id = get_consumer_id(headers)

    with {:ok, %{"data" => user}} <- Mithril.get_user_by_id(user_id, headers),
         {:ok, %{"data" => person}} <- @mpi_api.person(user["person_id"], headers),
         :ok <- validate_user_person(user, person),
         :ok <- check_user_blocked(user["is_blocked"]) do
      {:ok, person}
    end
  end

  def get_details(headers) do
    user_id = get_consumer_id(headers)

    with {:ok, %{"data" => user}} <- Mithril.get_user_by_id(user_id, headers),
         {:ok, %{"data" => person}} <- @mpi_api.person(user["person_id"], headers),
         :ok <- check_user_person_id(user, person["id"]) do
      {:ok, person}
    end
  end

  defp check_user_person_id(user, id) do
    if user["person_id"] == id do
      :ok
    else
      {:error, :forbidden}
    end
  end

  defp validate_tax_id(tax_id, person_tax_id, signed_content, signer) do
    with true <- tax_id == person_tax_id,
         true <- person_tax_id == signed_content["tax_id"],
         true <- signed_content["tax_id"] == signer["drfo"] do
      :ok
    else
      _ ->
        {:error, {:conflict, "Person that logged in, person that is changed and person that sign should be the same"}}
    end
  end

  defp validate_user_person(user, person) do
    if user["person_id"] == person["id"] and user["tax_id"] == person["tax_id"] do
      :ok
    else
      {:error, :access_denied}
    end
  end

  defp check_user_blocked(false), do: :ok

  defp check_user_blocked(true), do: {:error, :access_denied}
end
