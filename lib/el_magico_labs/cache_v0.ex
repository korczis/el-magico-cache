#defmodule ElMagicoLabs.Cache do
#  use GenServer
#
#  @cache_name :default_cache
#  @cache_opts [:named_table, :public, write_concurrency: true]
#  @default_resolvers []
#  @default_opts [
#    cache_name: @cache_name,
#    cache_opts: @cache_opts,
#    resolvers: %{}
#  ]
#
#  @type result ::
#          {:ok, any()}
#          | {:error, :timeout}
#          | {:error, :not_registered}
#
#  @doc """
#    Starts the Cache GenServer and creates an ETS table for storage.
#
#    ## Examples
#
#    ```elixir
#    {:ok, pid} = Cache.start_link()
#
#    ```
#  """
#  def start_link(state \\ %{}, opts \\ []) do
#    cache_name = Keyword.get(opts, :cache_name, @cache_name)
#    cache_opts = Keyword.get(opts, :cache_opts, @cache_opts)
#    name = Keyword.get(opts, :name, __MODULE__)
#    resolvers = Map.get(state, :resolvers, @default_resolvers)
#
#    with _ <- :ets.new(cache_name, cache_opts) do
#      mod_state =%{
#        cache_name: cache_name,
#        resolvers: resolvers,
#        data: %{}
#      }
#
#      mod_opts = [
#        name: name
#      ]
#
#      {:ok,_pid} = GenServer.start_link(__MODULE__, mod_state, mod_opts)
#    end
#  end
#
#  @impl GenServer
#  def init(init_state \\ %{}, init_opts \\ @default_opts) do
#    state = init_state
#    _opts = Keyword.merge(@default_opts, init_opts)
#    {:ok, state}
#  end
#
#  @doc """
#  Returns the value for specified key - core of the library
#
#  ## Algorithm
#    - Try to get looker from
#  """
#  @impl true
#  def handle_call({:get, key}, _from, state) do
#    handle_nil_key = fn ->
#      case get_in(state, [:resolvers, key]) do
#        nil ->
#          fallback_reply = fallback_resolver()
#          {:reply, fallback_reply, state}
#
#        looker ->
#          new_val = looker.()
#          {:reply, {:ok, new_val}, state}
#      end
#    end
#
#    with val_now <- Map.get(state[:data] || %{}, key) do
#      case val_now do
#        nil ->
#          handle_nil_key.()
#        val ->
#          {:reply, {:ok, val}, state}
#      end
#    else
#      _ -> {:error, :not_good}
#    end
#  end
#
#  @doc """
#  Here we just "alias" register_func to comply with requirements and also be more consistenti naming
#  """
#  def handle_call({:register_func, looker}, from, state), do: handle_call({:register_resolver, looker}, from, state)
#
#  @impl true
#  @doc """
#    Returns the value for specified key and expiry time.
#
#    ## Parameters
#    - `key` - The key to retrieve the value for
#    - `expiry_time` - The time in milliseconds until the value should be considered expired
#
#    ## Examples
#    ```elixir
#    {:ok, pid} = Cache.start_link()
#    Cache.register_resolver(:my_key, &(&1 + 1))
#    Cache.handle_call({:get, :my_key, 1000}, _from, state)
#    # => {:ok, 2}
#    ```
#  """
#  def handle_call({:get, key, expiry_time}, _from, state) do
#    with {:ok, value} <- get_value(key, state),
#         {:ok, new_state} <- update_expiry(key, expiry_time, state) do
#      {:reply, {:ok, value}, new_state}
#    else
#      {:error, :not_found} -> handle_not_found(key, state)
#      {:error, _} -> {:error, :not_good}
#    end
#  end
#
#  defp get_value(key, state) do
#    case Map.get(state[:data] || %{}, key) do
#      nil -> handle_not_found(key, state)
#      value -> {:ok, value}
#    end
#  end
#
#  defp handle_not_found(key, state) do
#    case get_in(state, [:resolvers, key]) do
#      nil -> {:error, :not_found}
#      resolver ->
#        value = resolver.()
#        update_value(key, value, state)
#    end
#  end
#
#  defp update_value(key, value, state) do
#    new_state = update_in(state, [:data, key], fn _ -> value end)
#    {:ok, new_state}
#  end
#
#  defp update_expiry(key, expiry_time, state) do
#    new_state = update_in(state, [:data, key, :expiry], fn _ -> :timer.seconds(expiry_time/1000) end)
#    {:ok, new_state}
#  end
#
#
#  @impl true
#  def handle_call(:get_state, _from, state) do
#    {:reply, state, state}
#  end
#
#  def fallback_resolver() do
#    {:error, "No resolver was provided"}
#  end
#
#  """
#  This code checks for whether a value for a given key has expired or not.
#  If it has, it will resolve the value again using the resolver function provided when it was registered.
#  If the value has not expired, it will return the cached value.
#  The `expired?` function takes the time the value was added and the expiry
#  time (in seconds) and compares them to the current time to determine whether the value has expired or not.
#  """
#  def expired?(time_added, expiry_time) do
#    current_time = System.monotonic_time()
#    (current_time - time_added) > expiry_time
#  end
#end