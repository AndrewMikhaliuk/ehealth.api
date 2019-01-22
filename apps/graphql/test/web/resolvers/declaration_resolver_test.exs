defmodule GraphQLWeb.DeclarationResolverTest do
  @moduledoc false

  use GraphQLWeb.ConnCase, async: false

  import Core.Expectations.Mithril, only: [nhs: 1]
  import Core.Factories
  import Core.Utils.TypesConverter, only: [atoms_to_strings: 1]
  import Mox

  alias Ecto.UUID
  alias Absinthe.Relay.Node

  @declaration_fields """
    id
    databaseId
    declarationNumber
    startDate
    endDate
    signedAt
    status
    scope
    reason
    reasonDescription
    legalEntity{id kveds}
    division{id email}
    employee{id start_date employee_type}
    person{
      id
      databaseId
      unzr
      addresses {
        settlementType
        zip
      }
    }

    declarationAttachedDocuments{
      type
      url
    }
  """

  @declaration_pending_query """
    query DeclarationsPendingQuery($filter: PendingDeclarationFilter, $orderBy: DeclarationOrderBy){
      pendingDeclarations(first: 10, filter: $filter, orderBy: $orderBy){
        nodes{
          #{@declaration_fields}
        }
      }
    }
  """

  @declaration_by_id_query """
    query declarationQuery($id: ID!) {
      declaration(id: $id) {
        #{@declaration_fields}
      }
    }
  """

  @declaration_by_number_query """
    query DeclarationByNumberQuery($declarationNumber: String!) {
      declarationByNumber(declarationNumber: $declarationNumber) {
        #{@declaration_fields}
      }
    }
  """

  @terminare_declaration_query """
    mutation TerminateDeclaration($input: TerminateDeclarationInput!){
      terminateDeclaration(input: $input){
        declaration{
          id
          databaseId
          reasonDescription
          legalEntity{
            id
            databaseId
          }
        }
      }
    }
  """

  @status_pending "pending_verification"

  setup :verify_on_exit!
  setup :set_mox_global

  setup %{conn: conn} do
    conn = put_scope(conn, "declaration:read declaration:terminate")

    {:ok, %{conn: conn}}
  end

  describe "pending declarations list" do
    test "success with search params", %{conn: conn} do
      persons = build_list(8, :mpi_person)
      documents = [%{"url" => "http://link-to-documents.web", "type" => "person.no_tax_id"}]

      declarations =
        [
          persons,
          insert_list(8, :prm, :division),
          insert_list(8, :prm, :employee),
          insert_list(8, :prm, :legal_entity),
          insert_list(8, :il, :declaration_request, documents: documents)
        ]
        |> Enum.zip()
        |> Enum.map(fn {person, division, employee, legal_entity, declaration_request} ->
          build(:ops_declaration,
            status: @status_pending,
            person_id: person.id,
            division_id: division.id,
            employee_id: employee.id,
            legal_entity_id: legal_entity.id,
            declaration_request_id: declaration_request.id
          )
        end)

      expect(RPCWorkerMock, :run, fn _, _, :search_declarations, _ -> {:ok, declarations} end)
      expect(RPCWorkerMock, :run, fn _, _, :search_persons, _ -> {:ok, persons} end)

      variables = %{
        filter: %{reason: "NO_TAX_ID"},
        orderBy: "STATUS_ASC"
      }

      resp_body =
        conn
        |> post_query(@declaration_pending_query, variables)
        |> json_response(200)

      resp_entities = [resp_entity | _] = get_in(resp_body, ~w(data pendingDeclarations nodes))

      refute resp_body["errors"]
      assert 8 == length(resp_entities)

      query_fields =
        ~w(id databaseId declarationNumber startDate endDate signedAt status scope reason reasonDescription legalEntity division employee person declarationAttachedDocuments)

      assert Enum.all?(query_fields, &Map.has_key?(resp_entity, &1))
      assert hd(resp_entity["person"]["addresses"])["zip"]

      assert hd(resp_entity["declarationAttachedDocuments"])["url"]
    end

    test "success: empty results", %{conn: conn} do
      expect(RPCWorkerMock, :run, fn _, _, :search_declarations, _ -> {:ok, []} end)
      variables = %{order_by: "STATUS_ASC"}

      resp_body =
        conn
        |> post_query(@declaration_pending_query, variables)
        |> json_response(200)

      resp_entities = get_in(resp_body, ~w(data pendingDeclarations nodes))

      refute resp_body["errors"]
      assert [] == resp_entities
    end
  end

  describe "get by id and number" do
    setup %{conn: conn} do
      division = insert(:prm, :division)
      employee = insert(:prm, :employee)
      legal_entity = insert(:prm, :legal_entity)
      person = build(:mpi_person)

      declaration =
        build(:ops_declaration,
          division_id: division.id,
          employee_id: employee.id,
          legal_entity_id: legal_entity.id,
          person_id: person.id
        )

      %{conn: conn, declaration: declaration, person: person}
    end

    test "success by id", %{conn: conn, declaration: declaration, person: person} do
      expect(RPCWorkerMock, :run, fn _, _, :get_declaration, _ -> declaration end)
      expect(RPCWorkerMock, :run, fn _, _, :search_persons, _ -> {:ok, [person]} end)

      id = Node.to_global_id("Declaration", declaration.id)
      variables = %{id: id}

      resp_body =
        conn
        |> post_query(@declaration_by_id_query, variables)
        |> json_response(200)

      resp_entity = get_in(resp_body, ~w(data declaration))

      refute resp_body["errors"]
      assert id == resp_entity["id"]
      assert declaration.id == resp_entity["databaseId"]
    end

    test "success by declaration number", %{conn: conn, declaration: declaration, person: person} do
      %{id: declaration_id, declaration_number: declaration_number} = declaration

      expect(RPCWorkerMock, :run, fn _, _, :get_declaration, _ -> declaration end)
      expect(RPCWorkerMock, :run, fn _, _, :search_persons, _ -> {:ok, [person]} end)

      id = Node.to_global_id("Declaration", declaration_id)
      variables = %{declarationNumber: declaration_number}

      resp_body =
        conn
        |> post_query(@declaration_by_number_query, variables)
        |> json_response(200)

      resp_entity = get_in(resp_body, ~w(data declarationByNumber))

      refute resp_body["errors"]
      assert id == resp_entity["id"]
      assert declaration_id == resp_entity["databaseId"]
      assert declaration_number == resp_entity["declarationNumber"]
    end

    test "not found by id", %{conn: conn} do
      expect(RPCWorkerMock, :run, fn _, _, :get_declaration, _ -> nil end)
      variables = %{id: Node.to_global_id("Declaration", UUID.generate())}

      resp_body =
        conn
        |> post_query(@declaration_by_id_query, variables)
        |> json_response(200)

      %{"errors" => [error]} = resp_body

      refute get_in(resp_body, ~w(data declaration))
      assert "NOT_FOUND" == error["extensions"]["code"]
    end

    test "not found by declaration number", %{conn: conn} do
      expect(RPCWorkerMock, :run, fn _, _, :get_declaration, _ -> nil end)
      variables = %{declarationNumber: Node.to_global_id("Declaration", UUID.generate())}

      resp_body =
        conn
        |> post_query(@declaration_by_number_query, variables)
        |> json_response(200)

      %{"errors" => [error]} = resp_body

      refute get_in(resp_body, ~w(data declarationByNumber))
      assert "NOT_FOUND" == error["extensions"]["code"]
    end
  end

  describe "terminate declaration" do
    test "success", %{conn: conn} do
      database_id = UUID.generate()
      person_id = UUID.generate()
      reason_description = "some reason"
      consumer_id = UUID.generate()

      %{id: client_id} = insert(:prm, :legal_entity)
      person = build(:person, id: person_id)
      declaration = build(:declaration, id: database_id, person_id: person_id, legal_entity_id: client_id)

      nhs(2)

      expect(OPSMock, :get_declaration_by_id, fn id, _headers ->
        assert id == database_id
        {:ok, %{"data" => atoms_to_strings(declaration)}}
      end)

      expect(OPSMock, :terminate_declaration, fn id, _, _ ->
        assert id == declaration.id

        {:ok, %{"data" => atoms_to_strings(declaration)}}
      end)

      expect(MPIMock, :person, fn id, _headers ->
        assert id == person_id
        {:ok, %{"data" => atoms_to_strings(person)}}
      end)

      expect(MithrilMock, :get_user_by_id, fn id, _ ->
        assert id == consumer_id

        {:ok,
         %{
           "data" => %{
             "id" => id,
             "email" => "mis_bot_1493831618@user.com",
             "type" => "user",
             "person_id" => person_id
           }
         }}
      end)

      variables = %{input: %{id: Node.to_global_id("Declaration", database_id), reason_description: reason_description}}

      resp_body =
        conn
        |> put_client_id(client_id)
        |> put_consumer_id(consumer_id)
        |> post_query(@terminare_declaration_query, variables)
        |> json_response(200)

      resp_entity = get_in(resp_body, ~w(data terminateDeclaration declaration))
      assert database_id == resp_entity["databaseId"]
      assert client_id == resp_entity["legalEntity"]["databaseId"]

      refute resp_body["errors"]
    end
  end
end
