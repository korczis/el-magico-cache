defmodule ElMagicoLabs.Cache.Api.CacheHandler do
  alias OpenApiSpex.{Operation, Schema}
  alias ElMagicoLabs.Cache.Api.Schemas

  import OpenApiSpex.Operation, only: [parameter: 5, response: 3, request_body: 4]
  alias ElMagicoLabs.Cache.Store, as: CacheStore

  import Plug.Conn

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
        description: "Lookup cached value by ID",
        operationId: "CacheHandler.Get",
        parameters: [
          parameter(:id, :path, %Schema{type: :string}, "Key", example: "author")
        ],
        responses: %{
          200 => response("CachedItem", "application/json", Schemas.CachedItem)
        }
      }
    end

    def load(conn = %Plug.Conn{params: %{id: id}}, _opts) do
      # FIXME: Possible DoS - possible exhausting of mem using non-existing symbols
      sym_id = CacheStore.get(id)

      res = case sym_id do
        {:error, _} = err -> err

        {:ok, value} ->
          %{
            id: id,
            value: value
          }
      end

      case res do
        nil ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(404, Jason.encode!(%{error: 'Not found', data: nil})) # inspect(reason)
          |> halt()

        {:error, reason} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(404, Jason.encode!(%{error: reason, data: nil})) # inspect(reason)
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
        data: Map.take(item, [:error, :id, :value])
      }
      |> Jason.encode!(pretty: true)
    end
  end

  defmodule Create do
    use Plug.Builder

    plug OpenApiSpex.Plug.CastAndValidate,
         json_render_error_v2: true,
         operation_id: "CacheHandler.Create"

    plug :create

    def open_api_operation(_) do
      %Operation{
        tags: ["cache"],
        summary: "Create cache resolver",
        description: "Create a cache resolver",
        operationId: "CacheHandler.Create",
        requestBody:
          request_body(
            "The user attributes",
            "application/json",
            Schemas.CachedItemResolver,
            required: true
          ),
        responses: %{
          201 => response("User", "application/json", Schemas.CachedItemResolver),
          422 => OpenApiSpex.JsonErrorResponse.response()
        }
      }
    end

    def create(conn = %Plug.Conn{body_params: %Schemas.CachedItemResolver{name: name, expression: expression}}, _opts) do
      {:ok, res, ctx} = Abacus.compile(expression)

      resolver = %{
        name: name,
        expression: expression
      }

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(201, render(resolver))
    end

    def render(item) do
      %{
        data: Map.take(item, [:name, :expression])
      }
      |> Jason.encode!(pretty: true)
    end
  end
end