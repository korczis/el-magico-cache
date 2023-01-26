defmodule ElMagicoLabs.Cache.Api.Router.Html do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/swaggerui", to: OpenApiSpex.Plug.SwaggerUI, init_opts: [path: "/api/openapi"]
end

defmodule ElMagicoLabs.Cache.Api.Router.Api do
  use Plug.Router

  plug OpenApiSpex.Plug.PutApiSpec, module: ElMagicoLabs.Cache.Api.ApiSpec
  plug :match
  plug :dispatch

  get "/api/cache/:id", to: ElMagicoLabs.Cache.Api.CacheHandler.Show
  get "/api/openapi", to: OpenApiSpex.Plug.RenderSpec
end

defmodule  ElMagicoLabs.Cache.Api.Router do
  use Plug.Router

  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  match "/api/*_", to: ElMagicoLabs.Cache.Api.Router.Api
  match "/*_", to: ElMagicoLabs.Cache.Api.Router.Html
end