defmodule GraphQL.Application do
  @moduledoc """
  This application provides GraphQL API for eHealth services.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(GraphQL.Endpoint, [])
    ]

    children =
      if Application.get_env(:graphql, :env) == :prod do
        children ++
          [
            {Cluster.Supervisor, [Application.get_env(:graphql, :topologies), [name: GraphQL.ClusterSupervisor]]}
          ]
      else
        children
      end

    opts = [strategy: :one_for_one, name: GraphQL.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    GraphQL.Endpoint.config_change(changed, removed)
    :ok
  end
end
