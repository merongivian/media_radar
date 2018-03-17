defmodule Tesla.Middleware.TupleForEconnrefused do
  def call(env, next, _opts) do
    try do
      {:ok, Tesla.run(env, next)}
    rescue
      e in Tesla.Error ->
        if Regex.run(~r/econnrefused/, e.message) do
          {:error, :econnrefused}
        else
          raise e
        end
    end
  end
end
