#defmodule ElMagicoLabs.PeriodicCache do
#  @moduledoc """
#  A cache that periodically re-evaluates and caches the result of registered functions.
#
#  Functions can be registered with a specified time-to-live (TTL) and refresh interval.
#  The cache will automatically re-evaluate the function and update the cached value
#  every `refresh_interval` milliseconds, as long as the cached value is older than `ttl` milliseconds.
#
#  Usage:
#
#      # Start the cache with a default TTL of 10 seconds and refresh interval of 5 seconds
#      {:ok, pid} = ElMagicoLabs.PeriodicCache.start_link(ttl: 10000, refresh_interval: 5000)
#
#      # Register a function with a TTL of 1 second and refresh interval of 500 milliseconds
#      ElMagicoLabs.PeriodicCache.register(fn -> :rand.uniform(100) end, ttl: 1000, refresh_interval: 500)
#
#      # Fetch the cached result of the function
#      ElMagicoLabs.PeriodicCache.fetch(fn -> :rand.uniform(100) end)
#      # => {:ok, 42}
#  """
#
#  use Horde.DynamicSupervisor
#  alias ElMagicoLabs.Registry, as: TaskRegistry
#
#  # Default values for TTL and refresh interval
#  @default_refresh_interval 60_0000
#  @default_ttl 60_0000
#
#  # Type specifications for various variables
#  @type ttl :: non_neg_integer
#  @type refresh_interval :: non_neg_integer
#  @type result :: any
#  @type cache_entry :: {:ok, result} | {:error, any}
#  @type cache :: any() # type(function, cache_entry)
#
#  @spec start_link(ttl: non_neg_integer, refresh_interval: non_neg_integer) :: {:ok, pid} | {:error, any}
#  def start_link(ttl \\ @default_ttl, refresh_interval \\ @default_refresh_interval) do
#    # Start the cache supervisor
#    Horde.DynamicSupervisor.start_link(__MODULE__, [ttl, refresh_interval], name: __MODULE__)
#  end
#
#  # @spec init([any, any]) :: {:ok, pid}
#  def init([ttl, refresh_interval])  do
#    # Initialize the cache and registry
#    cache = %{}
#    registry = Registry.start_link(:periodic_cache)
#
#    # Start a worker process to refresh the cache
#    children = [
#      # horde_member(fn -> worker(registry, cache, ttl, refresh_interval) end)
#    ]
#
#    # Supervisor options
#    opts = [strategy: :one_for_one, name: __MODULE__]
#
#    Horde.Supervisor.init(children, opts)
#  end
#
#  defp is_alive?(registry, key, ttl \\ @default_ttl) do
#    case TaskRegistry.whereis_name(registry, key) do
#      {:ok, task} ->
#        if Task.alive?(task) do
#          {:ok, task}
#        else
#          TaskRegistry.unregister(registry, key)
#          :error
#        end
#      :error -> :error
#    end
#  end
#
#  defp loop(registry, ttl \\ @default_ttl, refresh_interval \\ @default_refresh_interval) do
#    Task.sleep(refresh_interval)
#    TaskRegistry.whereis_name(registry, &(is_alive?(registry, &1, ttl)))
#    loop(registry, ttl, refresh_interval)
#  end
#
#  defp worker(function_id, ttl, refresh_interval) do
#    # Get the function from the registry using its function_id
#    function = Registry.get_function(function_id)
#
#    # Initialize the cache with the initial value returned by the function
#    cache = {function_id, function.()}
#
#    # Start a new process to handle the cache refreshing
#    spawn_link(fn ->
#      # Infinite loop to handle refreshing the cache
#      loop() do
#        # Sleep for the specified refresh interval
#        :timer.sleep(refresh_interval * 1000)
#
#        # Get the current time
#        current_time = :os.system_time(:millisecond)
#
#        # Check if the cached value is stale (i.e. if the time since it was last updated is greater than the ttl)
#        if current_time - cache.last_updated > (ttl * 1000) do
#          # If the value is stale, update the cache with the new value returned by the function
#          cache = {function_id, function.()}
#        end
#      end
#    end)
#
#    # Return the initial cache value
#    cache.value
#  end
#
#
#  @doc """
#  Register a function to be periodically re-evaluated and its result cached.
#  """
#  @spec register(function, ttl: ttl, refresh_interval: refresh_interval) :: :ok
#  def register(function, ttl \\ @default_refresh_interval, refresh_interval \\ @default_refresh_interval) do
#
#    Registry.register(:periodic_cache, function, [ttl, refresh_interval])
#  end
#
#  @doc """
#  Retrieve the cached value of a previously registered function.
#  """
#  def fetch(function) do
#    Task.Registry.get(:periodic_cache, function)
#  end
#
#  defp refresh_cache(registry, cache, ttl, refresh_interval) do
#    Enum.each(Registry.list(registry), &refresh_cache_entry/4)
#    Process.sleep(refresh_interval)
#    refresh_cache(registry, cache, ttl, refresh_interval)
#  end
#
#  defp refresh_cache_entry({function, {ttl, refresh_interval}}, registry, cache, _refresh_interval) do
#    result = function.()
#    cache = Map.put(cache, function, {result, :timer.now() + ttl})
#    Task.Registry.update(registry, function, {result, :timer.now() + ttl})
#  end
#
#  @spec refresh_interval() :: non_neg_integer()
#  def refresh_interval() do
#    Application.get_env(:el_magico_labs, :rehydrating_cache)[:refresh_interval]
#  end
#end
