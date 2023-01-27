# In-memory backend
defmodule InMemoryBackend do
  @moduledoc """
  An in-memory backend for the cache.
  """

  @cache %{}

  def get(key) do
    @cache[key]
  end

  def put(key, value) do
    @cache = Map.put(@cache, key, value)
  end

  def delete(key) do
    @cache = Map.delete(@cache, key)
  end
end