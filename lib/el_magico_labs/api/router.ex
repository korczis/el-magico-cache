defmodule ElMagicoLabs.RehydratingCache.Api.Router.Html do
  use Plug.Router
  # use Plug.Debugger

  plug :match
  plug :dispatch

  get "/", to: OpenApiSpex.Plug.SwaggerUI, init_opts: [path: "/api/openapi"]
  # get "/swaggerui", to: OpenApiSpex.Plug.SwaggerUI, init_opts: [path: "/api/openapi"]

  plug Plug.Static,
       at: "/doc",
       from: :el_magico_cache

  plug :not_found

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end
end

defmodule ElMagicoLabs.RehydratingCache.Api.Router.Api do
  use Plug.Router

  plug OpenApiSpex.Plug.PutApiSpec, module: ElMagicoLabs.RehydratingCache.Api.ApiSpec
  plug :match
  plug :dispatch

  get "/api/cache/:id", to: ElMagicoLabs.RehydratingCache.Api.CacheHandler.Show
  post "/api/cache", to: ElMagicoLabs.RehydratingCache.Api.CacheHandler.Create
  get "/api/openapi", to: OpenApiSpex.Plug.RenderSpec
end

defmodule  ElMagicoLabs.RehydratingCache.Api.Router do
  use Plug.Router
  # use Plug.Debugger

  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  match "/api/*_", to: ElMagicoLabs.RehydratingCache.Api.Router.Api
  match "/*_", to: ElMagicoLabs.RehydratingCache.Api.Router.Html
end