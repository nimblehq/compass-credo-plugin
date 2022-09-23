defmodule CompassCredoPlugin.Check.DoSingleExpression do
  use Credo.Check,
    base_priority: :normal,
    tags: [:controversial],
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

      def create_voucher(attrs \\ %{}),
      do:
        %Voucher{}
        |> change_voucher(attrs)
        |> Repo.insert()

      # Preferred
      if some_condition, do: "some_stuff"

      def validate_coupon(), do: :ok

      def create_voucher(attrs \\ %{}) do
        %Voucher{}
        |> change_voucher(attrs)
        |> Repo.insert()
      end
      """
    ]

  @matching_operations [:def, :defp, :if, :unless]

  @impl true
  def run(source_file, params) do
    ast =
      source_file
      |> Credo.SourceFile.source()
      |> Code.string_to_quoted!(token_metadata: true)

    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(ast, &traverse(&1, &2, issue_meta))
  end

  defp traverse({operation, meta, [name, body]} = ast, issues, issue_meta)
       when operation in @matching_operations do
    if contains_single_expression?(body) and contains_do_and_end?(meta) do
      trigger = "#{operation} #{elem(name, 0)}"
      {ast, Enum.reverse([issue_for(trigger, meta[:line], issue_meta) | issues])}
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

  def contains_do_and_end?(meta), do: !is_nil(meta[:do]) and !is_nil(meta[:end])

  defp issue_for(trigger, line_no, issue_meta) do
    format_issue(
      issue_meta,
      message: "`:#{trigger}` contains a single expression in a do ... end block. Use do: instead",
      trigger: "@#{trigger}",
      line_no: line_no
    )
  end
end
