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

  @impl true
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:def, _meta, [_, [{_, {:__block__, _, _}}]]} = _ast, _issues, _issue_meta) do
    IO.puts("Block function")

    # a = Credo.Code.to_lines(ast)
    # IO.inspect(a)
  end

  defp traverse(ast, issues, _), do: {ast, issues}
end

# a = length([{:do,
#  {:__block__, [],
#   [
#     {:=, [line: 7, column: 7],
#      [{:a, [line: 7, column: 5], nil}, {:+, [line: 7, column: 11], [5, 7]}]},
#     {:=, [line: 8, column: 7],
#      [
#        {:a, [line: 8, column: 5], nil},
#        {:+, [line: 8, column: 11], [{:a, [line: 8, column: 9], nil}, 1]}
#      ]},
#     {:a, [line: 9, column: 5], nil}
#   ]}}])

#   # IO.inspect(a)
