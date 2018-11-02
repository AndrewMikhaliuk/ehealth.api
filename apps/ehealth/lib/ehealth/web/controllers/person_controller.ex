defmodule EHealth.Web.PersonController do
  @moduledoc false

  use EHealth.Web, :controller

  alias Core.Declarations.Person
  alias Core.Persons
  alias EHealth.Web.DeclarationView

  action_fallback(EHealth.Web.FallbackController)

  @mpi_api Application.get_env(:core, :api_resolvers)[:mpi]

  def person_declarations(%Plug.Conn{req_headers: req_headers} = conn, %{"id" => id}) do
    with {:ok, declaration} <- Person.get_person_declaration(id, req_headers) do
      conn
      |> put_view(DeclarationView)
      |> render("show.json", declaration: declaration)
    end
  end

  def search_persons(conn, params) do
    with {:ok, persons, changes} <- Persons.search(params, conn.req_headers) do
      fields =
        changes
        |> Map.keys()
        |> Enum.map(&to_string/1)

      render(conn, "persons.json", %{persons: persons, fields: fields})
    end
  end

  def reset_authentication_method(conn, %{"id" => id}) do
    with {:ok, %{"meta" => %{}} = response} <- @mpi_api.reset_person_auth_method(id, conn.req_headers) do
      proxy(conn, response)
    end
  end
end
