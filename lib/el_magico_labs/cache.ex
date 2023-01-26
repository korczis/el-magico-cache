defmodule ElMagicoLabs.Cache do
  use GenServer

  @cache_name :default_cache
  @cache_opts [:named_table, :public, write_concurrency: true]
  @default_lookers []
  @default_opts [
    cache_name: @cache_name,
    cache_opts: @cache_opts,
    lookers: @default_lookers
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
    lookers = Keyword.get(opts, :lookers, @default_lookers)

    with _ <- :ets.new(cache_name, cache_opts) do
      mod_state = %{
        cache_name: cache_name,
        cache_opts: cache_opts,
        lookers: lookers,
        data: %{}
      }

      mod_opts = [
        name: name
      ]

      {:ok, pid} = GenServer.start_link(__MODULE__, mod_state, mod_opts)
    end
  end

  @impl GenServer
  def init(init_arg \\ %{}, init_opts \\ @default_opts) do
    state = Keyword.merge(@default_opts, init_opts)
    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    with val_now <- Map.get(state[:data], key) do
      case val_now do
        nil ->
          case get_in(state, [:lookers, key]) do
            nil ->
              {:reply, {:error, :no_looker}, state}

            looker ->
              new_val = looker.()
              new_state = update_in(state, [:lookers, key], fn _ -> new_val end)
              {:reply, new_val, new_state}
          end
        val ->
          {:reply, val, state}
      end
    end
  end

  @impl true
  def handle_call({:register_func, {key, f}}, _from, state) do
    # IO.inspect({"from", _from})
    #IO.inspect({"state"}, state)
    {_new_value, new_state} = get_and_update_in(state, [:lookers, key], fn -> f end)
    {:noreply, {:ok}, new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end