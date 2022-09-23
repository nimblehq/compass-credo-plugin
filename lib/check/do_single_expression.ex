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
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file = Credo.SourceFile.source(source_file)

    ast = Code.string_to_quoted!(source_file, line: 1, columns: true, token_metadata: true)

    Credo.Code.prewalk(ast, &traverse(&1, &2, issue_meta))
  end

  defp traverse({definition, _, [_fun, body]} = ast, issues, _issue_meta) when definition in @matching_operations do
    IO.inspect(body[:do])
    case body[:do] do
      {:__block__, _, _} ->
        # It's a block and will have multiple expression, so skip it
        IO.puts("BLOCK")
        {ast, issues}
      {_, a, b} ->
        IO.inspect(a)
        IO.inspect(b)
        IO.puts("not a block")
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}
end
