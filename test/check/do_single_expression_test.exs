defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "when there is any functions or if statements with a single line in the body" do
    test "reports an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        def some_function() do
           a = 5 + 7
           a + 5
        end

        def some_other_function(), do: :ok

        if some_condition do
          :ok
        end

      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issues()
    end
  end
end
