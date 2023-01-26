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

#  get "/api/users", to: PlugApp.UserHandler.Index
#  post "/api/users", to: PlugApp.UserHandler.Create
#  get "/api/users/:id", to: PlugApp.UserHandler.Show
  get "/api/openapi", to: OpenApiSpex.Plug.RenderSpec
end

defmodule  ElMagicoLabs.Cache.Api.Router do
  use Plug.Router

  alias ElMagicoLabs.Cache.Api.Router

  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  match "/api/*_", to: Router.Api
  match "/*_", to: Router.Html
end