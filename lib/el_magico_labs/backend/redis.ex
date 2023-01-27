## Redis backend
#defmodule RedisBackend do
#  @moduledoc """
#  A Redis backend for the cache.
#  """
#
#  @redis Application.get_env(:periodic_self_rehydrating_cache, :redis)
#
#  def get(key) do
#    @redis.get(key)
#  end
#
#  def put(key, value) do
#    @redis.set(key, value)
#  end
#
#  def delete(key) do
#    @redis.del(key)
#  end
#end