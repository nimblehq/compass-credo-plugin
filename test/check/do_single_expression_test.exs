defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "given two valid functions BUT the last IF statement contains a single expression with a do/end block" do
    test "reports an issue on the IF statement only" do
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
      |> assert_issue(fn issue -> assert issue.trigger == "@if some_condition" end)
    end
  end

  describe "given all the functions and if statements are invalid" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        def some_function() do
           a = 5 + 7
        end

        if some_condition do
          :ok
        end

        unless 1 > 2 do
          :ok
        end

        defp another_function() do
          :ok
        end

      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 4 end)
    end
  end

  describe "given a function that contains a single expression with a do/end block BUT it spans multiple lines" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        def create_voucher() do
          %Voucher{}
          |> change_voucher(attrs)
          |> Repo.insert()
        end

      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
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
