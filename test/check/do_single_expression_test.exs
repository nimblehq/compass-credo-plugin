defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "when there is any defdelegate after the first function" do
    test "reports an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        @default_value 10

        def validate_coupon() do
          :ok
        end

        def create_voucher(attrs \\ %{}),
          do:
            %Voucher{}
            |> change_voucher(attrs)
            |> Repo.insert()

        def foo, do: IO.inspect("foo")

        def some_func(),
          do: IO.puts("hi")

      end
      """

      # [issue] =
        module_source_code
        |> to_source_file()
        |> run_check(SingleStatement)

        # IO.inspect(issue)
    end
  end
end
