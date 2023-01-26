  defmodule ElMagicoLabs.Cache.Store do
  @default_cache ElMagicoLabs.Cache
  @default_cache_name :default_cache

  @default_opts [
    cache:  @default_cache
  ]

  def get(key, opts \\ @default_opts) do
    merged_opts(opts)
    |> IO.inspect()
    |> get_cache()
    |> GenServer.call({:get, key})

  end

  def register_func({_key, _func} = msg, opts \\ @default_opts) do
    merged_opts(opts)
    |> get_cache()
    |> GenServer.call({:register_func, msg})
  end

  def get_cache(opts \\ []) do
    merged_opts(opts)
    |> Keyword.merge(opts)
    |> Keyword.get(:cache, @default_cache)
  end

  def get_default_cache_name(), do: @default_cache_name

  def get_state(opts \\ @default_opts) do
    merged_opts(opts)
    |> get_cache()
    |> GenServer.call(:get_state)
  end

  def merged_opts(opts \\ []) do
    Keyword.merge(@default_opts, opts)
  end
end