defmodule ElMagicoLabs.RehydratingCache.ETSBackend do
  @table_name :cache

  def start_link() do
    :ets.new(@table_name, [:named_table, :public, :set])
    {:ok, self()}
  end

  def register(name, function, ttl \\ 3600, refresh_interval \\ 3600) do
    :ets.insert(@table_name, {name, function, ttl, refresh_interval})
  end

  def fetch(name) do
    case :ets.lookup(@table_name, name) do
      [] -> nil
      [{_, function, _, _}] -> function.()
    end
  end
end