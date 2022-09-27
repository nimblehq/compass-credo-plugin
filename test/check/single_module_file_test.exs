defmodule CompassCredoPlugin.Check.SingleModuleFileTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.SingleModuleFile

  describe "does not report issue" do
    test "given a file which only has one module, do not report any issue" do
      module_source_code = """
      defmodule SampleModuleBar do
        def print_number(number) do
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(SingleModuleFile)
      |> refute_issues()
    end

    test "given a file which only has one module and defstruct, do not report any issue" do
      module_source_code = """
      defmodule SampleModuleBar do
        defstruct [:retry_period_ms, :error_retry_limit]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(SingleModuleFile)
      |> refute_issues()
    end
  end

  describe "report an issue" do
    test "given a file has multiple modules including struct, reports 2 issues" do
      module_source_code = """
      defmodule SampleModuleBar do
        defstruct name: "John", age: 27

        defmodule SampleModuleBar do
        end
      end
      """

      [issue_1, issue_2] =
        module_source_code
        |> to_source_file()
        |> run_check(SingleModuleFile)
        |> assert_issues()

      assert issue_1.check == SingleModuleFile
      assert issue_2.check == SingleModuleFile
    end
  end
end
