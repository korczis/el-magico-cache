defmodule ElMagicoLabs.Cache.Api.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CachedItem do
    OpenApiSpex.schema(%{
      title: "CachedItem",
      description: "Cached item",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Item ID"},
        value: %Schema{type: :string, description: "Item value"},
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [:id, :value],
      example: %{
        "id" => "name",
        "value" => "Joe User"
      }
    })
  end
end