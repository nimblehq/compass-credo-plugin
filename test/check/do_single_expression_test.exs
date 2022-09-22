defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "when there is any functions or if statements with a single line in the body" do
    test "reports an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        @default_value 10

        def some_other_function() do
          a = 5 + 7
          a = a + 1
          a
        end

        if some_condition do
          :ok
        end

        def some_function() do
          :ok
        end

      end
      """

      # [issue] =
      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)

      # IO.inspect(issue)
    end
  end
end
