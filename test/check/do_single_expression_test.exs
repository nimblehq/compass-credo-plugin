defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "given two valid functions BUT the last IF statement contains a single expression with a do/end block" do
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
      |> assert_issue()
    end
  end

  describe "given two valid functions and a valid IF statement" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        def some_function() do
           a = 5 + 7
           a + 5
        end

        def some_other_function(), do: :ok

        if some_condition,
          do: :ok

      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end
end
