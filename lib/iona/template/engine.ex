# Taken in part from the Phoenix HTML project,
# https://github.com/phoenixframework/phoenix_html
defmodule Iona.Template.Engine do

  @moduledoc false

  use EEx.Engine

  defdelegate escape(value), to: Iona.Template.Helper

  @doc false
  def handle_body(body), do: body

  @doc false
  def handle_text(buffer, text) do
    quote do
      {:safe, [unquote(unwrap(buffer))|unquote(text)]}
    end
  end

  @doc false
  def handle_expr(buffer, "=", expr) do
    line   = line_from_expr(expr)
    expr   = expr(expr)
    buffer = unwrap(buffer)
    {:safe, quote do
       tmp1 = unquote(buffer)
       [tmp1|unquote(to_safe(expr, line))]
    end}
  end

  @doc false
  def handle_expr(buffer, "", expr) do
    expr   = expr(expr)
    buffer = unwrap(buffer)

    quote do
      tmp2 = unquote(buffer)
      unquote(expr)
      tmp2
    end
  end

  defp line_from_expr({_, meta, _}) when is_list(meta), do: Keyword.get(meta, :line)
  defp line_from_expr(_), do: nil

  # We can do the work at compile time
  defp to_safe(literal, _line) when is_binary(literal) or is_atom(literal) or is_number(literal) do
    to_iodata(literal)
  end

  # We can do the work at runtime
  defp to_safe(literal, line) when is_list(literal) do
    quote line: line, do: Iona.Template.Engine.to_iodata(unquote(literal))
  end

  # We need to check at runtime and we do so by
  # optimizing common cases.
  defp to_safe(expr, line) do
    # Keep stacktraces for protocol dispatch...
    fallback = quote line: line, do: Iona.Template.Engine.to_iodata(other)

    # However ignore them for the generated clauses to avoid warnings
    quote line: :keep do
      case unquote(expr) do
        {:safe, data} -> data
        bin when is_binary(bin) -> Iona.Template.Engine.escape(bin)
        other -> unquote(fallback)
      end
    end
  end

  defp expr(expr) do
    Macro.prewalk(expr, &handle_assign/1)
  end
  defp handle_assign({:@, meta, [{name, _, atom}]}) when is_atom(name) and is_atom(atom) do
    quote line: meta[:line] || 0 do
      Iona.Template.Engine.fetch_assign(var!(assigns), unquote(name))
    end
  end
  defp handle_assign(arg), do: arg

  @doc false
  def fetch_assign(assigns, key) when is_map(assigns) do
    fetch_assign(Map.to_list(assigns), key)
  end
  def fetch_assign(assigns, key) do
    case Keyword.fetch(assigns, key) do
      :error ->
        raise ArgumentError, message: """
        assign @#{key} not available in eex template. Available assigns: #{inspect Keyword.keys(assigns)}
        """
      {:ok, val} -> val
    end
  end

  defp unwrap({:safe, value}), do: value
  defp unwrap(value), do: value

  def to_iodata({:safe, str}) do
    str |> to_string
  end
  def to_iodata([h|t]) do
    [to_iodata(h)|to_iodata(t)]
  end
  def to_iodata([]) do
    []
  end
  def to_iodata(value) do
    value |> to_string |> escape
  end

end
