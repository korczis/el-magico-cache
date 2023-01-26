defmodule EqLabs.Cache.Store do
  @default_cache EqLabs.Cache
  @default_opts [
    cache:  @default_cache
  ]

  def get(key, opts \\ @default_opts) do
    opts
    |> get_cache()
    |> GenServer.call({:get, key})

  end

  def register_func({_key, _func} = msg, opts \\ @default_opts) do
    opts
    |> get_cache()
    |> GenServer.call({:register_func, msg})
  end

  def get_cache(opts \\ []) do
    @default_opts
    |> Keyword.merge(opts)
    |> Keyword.get(:cache, @default_cache)
  end

  def get_state(opts \\ @default_opts) do
    opts
    |> get_cache()
    |> GenServer.call(:get_state)
  end
end