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
    a = Credo.Code.to_lines(source_file)
    IO.inspect(a)

    # issue_meta = IssueMeta.for(source_file, params)

    # Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end
end
