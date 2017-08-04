# Enable PostGIS for Ecto
Postgrex.Types.define(
  EHealth.PRM.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison
)
