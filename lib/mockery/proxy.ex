defmodule Mockery.Proxy do
  alias Mockery.Utils
  alias Mockery.Error

  def unquote(:"$handle_undefined_function")(name, args) do
    [{_h, mod} | rest] = Enum.reverse(args)
    args = Enum.reverse(rest)

    arity = Enum.count(args)
    fun_tuple = {name, arity}
    key1 = Utils.dict_mock_key(mod, [{name, arity}])
    key2 = Utils.dict_mock_key(mod, name)

    if fun_tuple in mod.__info__(:functions) do
      case Process.get(key1) || Process.get(key2) do
        nil ->
          apply(mod, name, args)
        fun when is_function(fun, arity) ->
          apply(fun, args)
        fun when is_function(fun) ->
          raise Error, "function used for mock should have same arity as original"
        value ->
          value
      end
    else
      md = mod |> Module.split() |> Enum.join(".")

      raise Error, "function #{md}.#{name}/#{arity} is undefined or private"
    end
  end
end
