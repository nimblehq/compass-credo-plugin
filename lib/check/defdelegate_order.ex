defmodule CompassCredoPlugin.Check.DefdelegateOrder do
  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
        Prefer placing defdelegate functions the functions.

        # Less preferred
        defmodule App.UserView do
          alias App.SharedView

          # All the other module attributes, directives, and macros go here ...

          # All the normal functions go here ...

          defdelegate formatted_username(user), to: SharedView
        end

        # Preferred
        defmodule App.UserView do
          alias App.SharedView

          # All the other module attributes, directives, and macros go here ...

          defdelegate formatted_username(user), to: SharedView

          # All the normal functions go here ...
        end
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    {_, attributes_after_first_function} =
      source_file
      |> extract_functions()
      |> split_by_first_function()

    attributes_after_first_function
    |> Enum.filter(fn {attribute, _} -> attribute == :defdelegate end)
    |> Enum.map(fn {_, meta} ->
      format_issue(
        issue_meta,
        message:
          "Prefer placing defdelegate functions at the top of the module, just before the normal functions.",
        line_no: meta[:line]
      )
    end)
  end

  defp extract_functions(source_file) do
    source_file
    |> Credo.Code.prewalk(
      fn
        {attribute, meta, _} = ast, functions when attribute in [:def, :defp, :defdelegate] ->
          {ast, [{attribute, meta} | functions]}

        ast, functions ->
          {ast, functions}
      end,
      []
    )
    |> Enum.reverse()
  end

  defp split_by_first_function(functions) do
    Enum.split_while(functions, fn {attribute, _} -> attribute not in [:def, :defp] end)
  end
end
