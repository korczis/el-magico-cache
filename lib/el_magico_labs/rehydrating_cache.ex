defmodule PeriodicSelfRehydratingCache do
  @moduledoc """
  A module for implementing a periodic self-rehydrating cache. The cache is able to
  register 0-arity functions (each under a new key) that will recompute periodically
  and store their results in the cache for fast-access instead of being called every
  time the values are needed.

  ## Data Flow

  The following diagram illustrates the data flow in the cache:

  +-------------+     +--------------+     +-------------+
  |             |     |              |     |             |
  | Supervisor  | <--> | GenServer    | <--> | TaskPool    |
  |             |     |              |     |             |
  +-------------+     +--------------+     +-------------+

  1. The cache is started by the `Cache.Supervisor` which supervises a `Cache.GenServer` and a `Task.Supervisor`.
  2. The `Cache.GenServer` keeps track of all registered functions and their metadata (e.g. ttl and refresh_interval).
  3. The `Task.Supervisor` is responsible for running the registered functions at the specified intervals.
  4. The `TaskPool` is used to parallelize the execution of the registered functions.

  ## Function registration

    Functions can be registered with the cache by calling `Cache.register/4`. The function must be a 0-arity function and will be passed the following arguments:
    * `key` - the unique identifier for the function
    * `fn` - the function to be registered and executed periodically
    * `ttl` - the time to live for the cached result in seconds
    * `refresh_interval` - the interval at which the function should be re-executed in seconds

  ## Cached Results

  Results of the registered functions are stored in the cache with their corresponding key. Each cached result has a `ttl` value associated with it. Once the `ttl` for a cached result expires, the corresponding function will be re-executed and the result will be stored in the cache again.


   ## Concurrent Execution and Waiting on Task Results

  Tasks are executed concurrently, and the `TaskPool` is used to parallelize the execution of the registered functions. The `Task.Supervisor` is responsible for running the registered functions at the specified intervals. When a task finishes execution, the result is stored in the cache. If a task is still running when its `ttl` expires, the `TaskPool` will wait for the result of the running task before re-executing the function.
  """




  @doc """
  Registers a function under a key, with a given time-to-live (TTL) and
  refresh interval. The function will be recomputed and its result stored in
  the cache at the specified interval, and will be deleted from the cache
  after the specified TTL.

  The register/4 function is a public API that allows users to register a 0-arity function with the cache. It takes in the following arguments:

  name: the name of the function, which will be used as the key to store and retrieve the function's result in the cache
  function: the 0-arity function that needs to be registered
  ttl: the "time to live" of the cached result in seconds (defaults to 3600 seconds if not provided)
  refresh_interval: the interval at which the function should be re-computed and the cache should be updated in seconds (defaults to 3600 seconds if not provided)`

  ## Examples

  iex> PeriodicSelfRehydratingCache.register(:weather_data, fn -> :ok end, ttl: 3600, refresh_interval: 600)
  :ok

  iex> PeriodicSelfRehydratingCache.get(:weather_data)
  :ok
  """
  def register(name, function, ttl \\ 3600, refresh_interval \\ 3600) do
    GenServer.call(__MODULE__, {:register, name, function, ttl, refresh_interval})
  end

  def handle_call({:register, name, function, ttl, refresh_interval}, _from, state) do
    # First, we check if the function is already registered under the given name
    case Map.fetch(state, name) do
      {:ok, _} ->
        {:reply, {:error, :function_already_registered}, state}
      :error ->
        # If the function is not already registered, we create a new task that will
        # periodically re-compute the function's result and store it in the cache
        task = Task.start_link(fn -> rehydrate(name, function, ttl) end)
        # We also store the task's pid, the ttl and the refresh_interval in the state
        new_state = Map.put(state, name, {task, ttl, refresh_interval})
        {:reply, {:ok, task}, new_state}
    end
  end

  @doc """
  Gets the value stored under a key from the cache.

  ## Examples

  iex> PeriodicSelfRehydratingCache.register(:weather_data, fn -> :ok end, ttl: 3600, refresh_interval: 600)
  :ok

  iex> PeriodicSelfRehydratingCache.get(
  """
end
