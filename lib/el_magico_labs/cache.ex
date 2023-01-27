defmodule Cache do
  @moduledoc """
  A module for implementing a periodic self-rehydrating cache. The cache is able to
  register 0-arity functions (each under a new key) that will recompute periodically
  and store their results in the cache for fast-access instead of being called every
  time the values are needed.

  ## How it works

  A periodic self-rehydrating cache is a system that allows you to register functions and have their results cached for a certain
  period of time, after which they are re-computed and the cache is updated. This can be useful in situations where
  you have expensive computations that need to be performed regularly, but the results do not change often.

  ## Data Flow

  The Cache module is a powerful tool for implementing a periodic self-rehydrating cache in Elixir.
  It allows users to register 0-arity functions (each under a new key) that will recompute periodically
  and store their results in the cache for fast-access instead of being called every time the values are needed.

  The following diagram illustrates the data flow in the cache:

    +-------------+      +--------------+      +-------------+
    |             |      |              |      |             |
    | Supervisor  | <--> | GenServer    | <--> | TaskPool    |
    |             |      |              |      |             |
    +-------------+      +--------------+      +-------------+

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


  ## Registering a Function

  The register/4 function is a public API that allows users to register a 0-arity function with the cache. It takes in the following arguments:

    * name: the name of the function, which will be used as the key to store and retrieve the function's result in the cache
    function: the 0-arity function that needs to be registered
    * ttl: the "time to live" of the cached result in seconds (defaults to 3600 seconds if not provided)
    * refresh_interval: the interval at which the function should be re-computed and the cache should be updated in seconds (defaults to 3600 seconds if not provided)

  The function uses the GenServer.call/3 function to send a message to the Cache.GenServer process,
  which is responsible for registering the function and starting a task that will periodically re-compute the function's
  result and store it in the cache.


  In the handle_call/3 function, the GenServer process first checks if the function is already registered under the
  given name by looking it up in the state, which is a map of registered functions and their
  metadata (e.g. ttl and refresh_interval). If the function is already registered, an error message is returned.
  If it is not registered, a new task is created using the Task.start_link/1 function, passing in a function that calls rehydrate/3.
  This function will periodically re-compute the function's result and store it in the cache. The task's pid, the ttl and
  the refresh_interval are also stored in the state, so that they can be accessed later if needed.

  ## Rehydration

  The process of periodically re-computing the function's result and updating the cache is referred to as "rehydration".
  This is typically done by a separate function, such as Cache.rehydrate/3, which is called by the task started in
  the Cache.register/4 function.

  This function takes the name of the function, the pid of the task, and the current state of the cache as arguments.
  It then calls the registered function, computes the result, and updates the cache with the new result.

  ## Cached Results

  Results of the registered functions are stored in the cache with their corresponding key. Each cached result has a `ttl` value associated with it. Once the `ttl` for a cached result expires, the corresponding function will be re-executed and the result will be stored in the cache again.

  ## Concurrent Execution and Waiting on Task Results

  Tasks are executed concurrently, and the `TaskPool` is used to parallelize the execution of the registered functions.
  The `Task.Supervisor` is responsible for running the registered functions at the specified intervals.
  When a task finishes execution, the result is stored in the cache. If a task is still running when its `ttl` expires, the `TaskPool`
  will wait for the result of the running task before re-executing the function.

  ## Caching Strategies

  There are different caching strategies that can be used to improve the performance of the cache. Some examples include:

    * Distributed caching: by distributing the cache across multiple nodes, you can improve the scalability and availability of the cache.
    * Pub/sub or event-driven caching: by using a pub/sub or event-driven approach, you can have the cache automatically

  ## Distributed Caching

  The Cache module can also be used in a distributed environment.
  One way to accomplish this is by using a Pub-Sub model, where each node in the cluster subscribes to updates for a
  specific key and the updates are broadcasted to all subscribers. Another way is by using a distributed cache,
  where each node in the cluster has its own local cache and a mechanism for propagating updates and invalidations across the cluster.
  Additionally, a message bus can also be used to facilitate communication between the cache processes in a distributed system.

  To implement a distributed cache using the above methods, the Cache module would need to be modified to include additional
  functionality for subscribing to updates, broadcasting updates, and propagating invalidations. Additionally, a mechanism for
  resolving conflicts and ensuring consistency across the cluster would also need to be implemented.

  One of the key advantages of using a distributed cache is that it can significantly improve the performance and scalability of the system,
  as the cache can be spread across multiple nodes, reducing the load on a single node. However, it also increases the complexity of
  the system and requires additional resources to maintain consistency across the cluster.

  To illustrate the use of distributed cache, let's consider the following diagram, which shows a cluster of 3 nodes, each running
  an instance of the Cache module and a mechanism for communicating updates between the nodes:

  ```
  +----------+     +----------+     +----------+
  |  Node 1  |---->|  Node 2  |---->|  Node 3  |
  +----------+     +----------+     +----------+


  In this diagram, each node represents a single instance of the Cache module, running on a separate machine or process.
  The arrows represent the mechanism for communicating updates between the nodes, which can be implemented using a
  Pub-Sub pattern, where each node subscribes to updates from the other nodes and publishes its own updates.

  When a function is registered on one node, it is also replicated to the other nodes in the cluster. When the function is called and its result is
  cached on one node, that result is also replicated to the other nodes. This allows for a highly available and performant cache, as any node in the
  cluster can serve a request for a cached result.

  In addition to this, the system can be configured to use a distributed cache like Memcached or Redis.
  This allows the cache to be shared across multiple servers, improving performance and reliability.

  As a result, the cache is no longer tied to a single server, making it more resilient to failures and much easier to scale.

  To further improve the robustness and performance of the cache, it can be clustered using a distributed cache or a bus mechanism.
  This allows the cache to be sharded across multiple nodes, increasing the capacity of the cache and reducing the impact of individual node failures.

  Overall, the register/4 function is an important part of the Cache module, allowing users to register functions and manage their cache in a performant and reliable way.
  With this architecture, it's possible to achieve a highly available, performant and easily scalable cache.

  Each node in the cluster has its own local cache, but also communicates with the other nodes to propagate updates and invalidations.
  For example, when a value is updated on Node 1, it will be broadcasted to Node 2 and Node 3, which will update their local caches accordingly.
  This ensures that the cache remains consistent across the entire cluster.

  In order to implement a distributed cache, the Cache module would need to be modified to include functionality for subscribing to updates,
  broadcasting updates, and propagating invalidations. Additionally, a mechanism for resolving conflicts and ensuring consistency across the cluster would also need to be implemented.

  In conclusion, the Cache module provides a powerful and flexible way to implement a cache in Elixir applications. It can be used to improve
  the performance and scalability of the system by storing the results of frequently called functions in a fast-access cache.
  It also allows for easy registration and management of the functions and their cache parameters. In distributed systems,
  it can also be extended to provide a distributed cache, which can improve performance and scalability even further by spreading the cache across multiple nodes.
  However, it also increases the complexity of the system and requires additional resources to maintain consistency across the cluster.

  In a distributed cache, multiple nodes in a cluster share the same cache data. When a node updates its cache,
  it publishes the update to the other nodes in the cluster through a message bus. The other nodes then subscribe to
  these updates and update their own cache accordingly. This ensures that all nodes in the cluster have the same up-to-date cache data.

  The register/4 function can still be used in a distributed cache environment. When a node registers a function, it also publishes the registration to
  the other nodes in the cluster. Each node then creates its own task to periodically re-compute the function's result and update its own cache.

  In this way, a distributed cache can improve the performance and scalability of the system, as it allows multiple nodes to handle requests and share the load.
  It also provides high availability, as if one node goes down, the other nodes can continue to serve requests and provide the cached data.

  The use of a message bus or Pub-Sub mechanism allows for real-time updates to be propagated across the cluster, ensuring that all nodes have the most recent data.
  This is important for keeping the cache data consistent and up-to-date.
  ```

  ## Clustering

  In a clustered environment, the cache can be implemented using a variety of techniques such as
  distributed cache, pub-sub, or a message bus.

  ```
  +-------------+          +--------------+          +-------------+
  |             |   <-->   |              |   <-->   |             |
  | Node 1      |          | Distributed  |          | Message Bus |
  |             |          | Cache/PubSub |          |             |
  +-------------+          +--------------+          +-------------+

  ```

  ## Implementation Details

  The function uses the GenServer.call/3 function to send a message to the Cache.GenServer process, which is responsible for registering the function and starting a task that will periodically re-compute the function's result and store it in the cache.
  In the handle_call/3 function, we first check if the function is already registered under the given name by looking it up in the state, which is a map of registered functions and their metadata (e.g. ttl and refresh_interval). If the function is already registered, we return an error message. If it is not registered, we create a new task using the Task.start_link/1 function, passing in a function that calls rehydrate/3 which will periodically re-compute the function's result and store it in the cache. We also store the task's pid, the ttl and the refresh_interval in the state, so that we can later access this information if needed.

  ```txt
    +-------------+
    |             |
    |   Cache     |
    |             |
    +------+------+
           |
           | register_function/3
           |
           v
    +------+------+
    |             |
    |TaskScheduler|
    |             |
    +------+------+
           |
           | schedule_task/2
           |
           v
    +------+------+
    |             |
    |HordeSupervisor|
    |             |
    +------+------+
  ```

  """

  use GenServer

  @doc """
  Starts the cache by starting the `Cache.Supervisor`, `Cache.GenServer` and `Task.Supervisor`
  """
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Stops the cache by stopping the `Cache.Supervisor`
  """
  def stop do
    Supervisor.stop(__MODULE__)
  end

  @doc """
    Registers a 0-arity function with the cache and starts a task that periodically
    re-computes the function's result and stores it in the cache.
  """

  def register(name, function, ttl \\ 3600, refresh_interval \\ 3600) do
    GenServer.call(__MODULE__, {:register, name, function, ttl, refresh_interval})
  end

  def rehydrate(name, function, ttl) do
    # We execute the function and store the result in the cache
    result = function.()
    Cache.put(name, result, ttl)

    # We schedule the task to be executed again after the refresh_interval
    Process.sleep(refresh_interval)
    rehydrate(name, function, ttl)
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
end
