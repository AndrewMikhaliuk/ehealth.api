defmodule EHealth.Web.PersonView do
  @moduledoc false

  use EHealth.Web, :view
  alias Core.Persons.Renderer, as: PersonsRenderer

  def render("show.json", %{"person" => person}), do: render(__MODULE__, "show.json", person: person)

  def render("show.json", %{person: person}) do
    PersonsRenderer.render("show.json", person)
  end

  def render("persons.json", %{persons: persons, fields: fields}) do
    Enum.map(persons, fn person ->
      render(__MODULE__, "search_view.json", person: person, fields: fields)
    end)
  end

  def render("search_view.json", %{person: person, fields: fields}) do
    mandatory_fields =
      Map.take(
        person,
        ~w(id first_name second_name last_name birth_country birth_settlement master_persons merged_persons)
      )

    requested_fields =
      Enum.into(fields, %{}, fn field ->
        case field do
          "birth_certificate" ->
            documents = Map.get(person, "documents") || []
            {"documents", Enum.filter(documents, &(Map.get(&1, "type") == "BIRTH_CERTIFICATE"))}

          "phone_number" ->
            phones = Map.get(person, "phones") || []
            {"phones", Enum.filter(phones, &(Map.get(&1, "type") == "MOBILE"))}

          _ ->
            {field, Map.get(person, field)}
        end
      end)

    Map.merge(mandatory_fields, requested_fields)
  end

  def render("person_short.json", %{"person" => person}) do
    Map.take(person, ~w(
      id
      first_name
      last_name
      second_name
    ))
  end

  def render("person_short.json", _), do: %{}
end
