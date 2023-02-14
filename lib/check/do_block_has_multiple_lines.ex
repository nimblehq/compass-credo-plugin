defmodule CompassCredoPlugin.Check.DoBlockHasMultipleLines do
  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
      Prefer using multi-line function body if it spans multiple lines.

      # Less Preferred
      def create_voucher(attrs),
        do:
          %Voucher{}
          |> change_voucher(attrs)
          |> Repo.insert()

      # Preferred
      def create_voucher(attrs) do
        %Voucher{}
        |> change_voucher(attrs)
        |> Repo.insert()
      end
      """
    ]

  @matching_definition_types [:def, :defp, :if, :unless]
  @max_permitted_body_lines 1

  @impl true
  def run(source_file, params) do
    ast =
      source_file
      |> Credo.SourceFile.source()
      |> Code.string_to_quoted!(
        token_metadata: true,
        literal_encoder: &{:ok, {:__block__, &2, [&1]}}
      )

    issue_meta = IssueMeta.for(source_file, params)

    ast
    |> Credo.Code.prewalk(&traverse(&1, &2, issue_meta))
    |> Enum.reverse()
  end

  defp traverse({definition_type, meta, [_definition, body]} = ast, issues, issue_meta)
       when definition_type in @matching_definition_types do
    case not contains_do_and_end?(meta) do
      true ->
        handle_do(meta, body, ast, issues, issue_meta)

      false ->
        {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp handle_do(meta, body, ast, issues, issue_meta) do
    if total_body_lines(body) > @max_permitted_body_lines do
      {ast, [issue_for(meta[:line], get_check_error_message(), issue_meta) | issues]}
    else
      {ast, issues}
    end
  end

  defp contains_do_and_end?(meta), do: !is_nil(meta[:do]) and !is_nil(meta[:end])

  defp total_body_lines([{{_, do_meta, _}, {_, body_meta, _}}]),
    do: (body_meta[:closing][:line] || body_meta[:line]) - do_meta[:line]

  defp total_body_lines([{{_, do_meta, _}, {_, body_meta, _}}, _]),
    do: (body_meta[:closing][:line] || body_meta[:line]) - do_meta[:line]

  defp get_check_error_message,
    do: "Multiple lines in a do: block. Use do ... end instead"

  defp issue_for(line_no, message, issue_meta) do
    format_issue(
      issue_meta,
      message: message,
      line_no: line_no
    )
  end
end