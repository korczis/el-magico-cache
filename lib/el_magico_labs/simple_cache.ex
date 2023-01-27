defmodule ElMagicoLabs.SimpleCache do
  use GenServer

  @cache_name :default_cache
  @cache_opts [:named_table, :public, write_concurrency: true]
  @default_resolvers []
  @default_opts [
    cache_name: @cache_name,
    cache_opts: @cache_opts,
    resolvers: %{}
  ]

  @type result ::
          {:ok, any()}
          | {:error, :timeout}
          | {:error, :not_registered}

  @doc """
    Starts the Cache GenServer and creates an ETS table for storage.

    ## Examples

    ```elixir
    {:ok, pid} = Cache.start_link()

    ```
  """
  def start_link(state \\ %{}, opts \\ []) do
    cache_name = Keyword.get(opts, :cache_name, @cache_name)
    cache_opts = Keyword.get(opts, :cache_opts, @cache_opts)
    name = Keyword.get(opts, :name, __MODULE__)
    resolvers = Map.get(state, :resolvers, @default_resolvers)

    with _ <- :ets.new(cache_name, cache_opts) do
      mod_state =%{
        cache_name: cache_name,
        resolvers: resolvers,
        data: %{}
      }

      mod_opts = [
        name: name
      ]

      {:ok,_pid} = GenServer.start_link(__MODULE__, mod_state, mod_opts)
    end
  end

  @impl GenServer
  def init(init_state \\ %{}, init_opts \\ @default_opts) do
    state = init_state
    _opts = Keyword.merge(@default_opts, init_opts)
    {:ok, state}
  end

  @doc """
  Returns the value for specified key - core of the library

  ## Algorithm
    - Try to get looker from
  """
  @impl true
  def handle_call({:get, key}, _from, state) do
    handle_nil_key = fn ->
      case get_in(state, [:resolvers, key]) do
        nil ->
          fallback_reply = fallback_resolver()
          {:reply, fallback_reply, state}

        looker ->
          new_val = looker.()
          {:reply, new_val, state}
      end
    end

    with val_now <- Map.get(state[:data] || %{}, key) do
      case val_now do
        nil ->
          handle_nil_key.()
        val ->
          {:reply, val, state}
      end
    else
      _ -> {:error, :not_good}
    end
  end

  @doc """
  Here we just "alias" register_func to comply with requirements and also be more consistenti naming
  """
  def handle_call({:register_func, looker}, from, state), do: handle_call({:register_resolvers, looker}, from, state)

  @impl true
  def handle_call({:register_resolvers, {_key, _f} = looker}, _from, state) do
    new_state = update_in(state, [:resolvers], fn resolvers -> Keyword.merge(resolvers, [looker])end)
    {:reply, :registered,  new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def fallback_resolver() do
    {:error, "No resolver was provided"}
  end
end