defmodule ElMagicoLabs.Cache.Api.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "Plug App",
        version: "1.0"
      },
      paths: %{
        "/api/cache/{id}" =>
          OpenApiSpex.PathItem.from_routes([
            %{verb: :get, plug: ElMagicoLabs.Cache.Api.CacheHandler.Show, opts: []}
          ])
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end