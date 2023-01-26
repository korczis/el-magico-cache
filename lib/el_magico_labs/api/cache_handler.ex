defmodule ElMagicoLabs.Cache.Api.CacheHandler do
  alias OpenApiSpex.{Operation, Schema}
  alias ElMagicoLabs.Cache.Api.Schemas
  import OpenApiSpex.Operation, only: [parameter: 5, request_body: 4, response: 3]

  alias ElMagicoLabs.Cache.Store, as: Cache

  defmodule Show do
    use Plug.Builder

    plug OpenApiSpex.Plug.CastAndValidate,
         json_render_error_v2: true,
         operation_id: "CacheHandler.Get"

    plug :load
    plug :show

    def open_api_operation(_) do
      %Operation{
        tags: ["cache"],
        summary: "Get key",
        description: "Lookup key by ID",
        operationId: "CacheHandler.Get",
        parameters: [
          parameter(:id, :path, %Schema{type: :string}, "Key", example: "name")
        ],
        responses: %{
          200 => response("CachedItem", "application/json", Schemas.CachedItem)
        }
      }
    end

    def load(conn = %Plug.Conn{params: %{id: id}}, _opts) do
      res = %{
        id: id,
        value: 43
      }
      case res do
        nil ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(404, ~s({"error": "Item not found"}))
          |> halt()

        item ->
          assign(conn, :item, item)
      end
    end

    def show(conn = %Plug.Conn{assigns: %{item: item}}, _opts) do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, render(item))
    end

    def render(item) do
      %{
        data: Map.take(item, [:id, :value])
      }
      |> Jason.encode!(pretty: true)
    end
  end

end