defmodule CompassCredoPlugin.Check.DoSingleExpression do
  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
      Use do: for single line if/unless statements

      Prefer using the single-line function as long as mix format command satisfies to keep the function body just in one line.

      Prefer using multi-line function body if it spans multiple lines.

      # Less Preferred
      def validate_coupon() do
        :ok
      end

      def list_by_ids(courier_company_ids) do
        where(CourierCompany, [company], company.id in ^courier_company_ids)
      end

      def build_error_message(purchase, _attrs)
          when purchase.product.is_shippable == false do
        "Purchase's product is not shippable"
      end

      def create_voucher(attrs),
        do:
          %Voucher{}
          |> change_voucher(attrs)
          |> Repo.insert()

      # Preferred
      def validate_coupon(), do: :ok

      def list_by_ids(courier_company_ids),
        do: where(CourierCompany, [company], company.id in ^courier_company_ids)

      def build_error_message(purchase, _attrs)
        when purchase.product.is_shippable == false,
        do: "Purchase's product is not shippable"

      def create_voucher(attrs) do
        %Voucher{}
        |> change_voucher(attrs)
        |> Repo.insert()
      end
      """
    ]

  @matching_definition_types [:def, :defp, :if, :unless]
  @min_required_do_end_body_lines 2
  @max_permitted_do_body_lines 1

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
    cond do
      contains_single_expression?(body) and contains_do_and_end?(meta) ->
        if total_do_end_lines(meta) < @min_required_do_end_body_lines do
          {ast, [issue_for(meta[:line], do_end_check_message(), issue_meta) | issues]}
        else
          {ast, issues}
        end

      contains_single_expression?(body) and not contains_do_and_end?(meta) ->
        if total_do_lines(body) > @max_permitted_do_body_lines do
          {ast, [issue_for(meta[:line], do_check_message(), issue_meta) | issues]}
        else
          {ast, issues}
        end

      true ->
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

  defp total_do_end_lines(meta), do: meta[:end][:line] - meta[:do][:line] - 1

  defp total_do_lines([{{_, do_meta, _}, {_, body_meta, _}}]),
    do: (body_meta[:closing][:line] || body_meta[:line]) - do_meta[:line]

  defp total_do_lines([{{_, do_meta, _}, {_, body_meta, _}}, _]),
    do: (body_meta[:closing][:line] || body_meta[:line]) - do_meta[:line]

  defp do_end_check_message,
    do: "Single expression and single line in a do ... end block. Use do: instead"

  defp do_check_message,
    do: "Multiple lines in a do: block. Use do ... end instead"

  defp issue_for(line_no, message, issue_meta) do
    format_issue(
      issue_meta,
      message: message,
      line_no: line_no
    )
  end
end
