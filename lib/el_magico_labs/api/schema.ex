defmodule ElMagicoLabs.Cache.Api.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CachedItem do
    OpenApiSpex.schema(%{
      title: "CachedItem",
      description: "Cached item",
      type: :object,
      properties: %{
        name: %Schema{type: :integer, description: "Item ID"},
        expression: %Schema{type: :string, description: "Item value"},
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [:name, :expression],
      example: %{
        "name" => "basic_1_plus_2",
        "expression" => "T1 + 2"
      }
    })
  end

  defmodule CachedItemResolver do
    OpenApiSpex.schema(%{
      title: "CachedItem",
      description: "Cached item",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "Resolver id"},
        expression: %Schema{type: :string, description: "Resolver expression"},
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [:name, :expression],
      example: %{
        "name" => "basic_1_plus_2",
        "expression" => "1 + 2"
      }
    })
  end
end