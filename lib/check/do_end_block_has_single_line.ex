defmodule CompassCredoPlugin.Check.DoEndBlockHasSingleLine do
  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
      Use do: for single line if/unless statements

      Prefer using the single-line function as long as mix format command satisfies to keep the function body just in one line.

      # Less Preferred
      if some_condition do
        "some_stuff"
      end

      def validate_coupon() do
        :ok
      end

      # Preferred
      if some_condition, do: "some_stuff"

      def validate_coupon(), do: :ok
      """
    ]

  @matching_definition_types [:def, :defp, :if, :unless]
  @min_required_body_lines 2

  @impl true
  def run(source_file, params) do
    ast =
      source_file
      |> Credo.SourceFile.source()
      |> Code.string_to_quoted!(token_metadata: true)

    issue_meta = IssueMeta.for(source_file, params)

    ast
    |> Credo.Code.prewalk(&traverse(&1, &2, issue_meta))
    |> Enum.reverse()
  end

  defp traverse({definition_type, meta, [_definition, body]} = ast, issues, issue_meta)
       when definition_type in @matching_definition_types do
    if contains_single_expression?(body) and contains_do_and_end?(meta) and
         total_body_lines(meta) < @min_required_body_lines do
      {ast, [issue_for(meta[:line], issue_meta) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp contains_single_expression?(body) do
    case body[:do] do
      {:__block__, _, _} ->
        false

      _ ->
        true
    end
  end

  defp contains_do_and_end?(meta), do: !is_nil(meta[:do]) and !is_nil(meta[:end])

  defp total_body_lines(meta), do: meta[:end][:line] - meta[:do][:line] - 1

  defp issue_for(line_no, issue_meta) do
    format_issue(
      issue_meta,
      message: "Single expression and single line in a do ... end block. Use do: instead",
      line_no: line_no
    )
  end
end
