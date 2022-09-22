defmodule CompassCredoPlugin.Check.RepeatingFragments do
  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
        Avoid repeating fragments in module names and namespaces.

        # Don't
        defmodule Todo.Todo do
          ...
        end

        # Do
        defmodule Todo.Item do
          ...
        end
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:defmodule, _meta, arguments} = ast, issues, issue_meta) do
    {ast, issues_for_module_names(arguments, issues, issue_meta)}
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp issues_for_module_names(body, issues, issue_meta) do
    case Enum.at(body, 0) do
      {:__aliases__, meta, names} ->
        rise_issue_for_repeating_fragments(names, meta, issues, issue_meta)

      _ ->
        issues
    end
  end

  defp rise_issue_for_repeating_fragments(names, meta, issues, issue_meta) do
    is_repeating? =
      names
      |> Enum.uniq()
      |> Enum.count() != Enum.count(names)

    if is_repeating? do
      [
        format_issue(
          issue_meta,
          message: "Avoid repeating fragments in module names and namespaces.",
          line_no: meta[:line]
        )
      ]
    else
      issues
    end
  end
end
