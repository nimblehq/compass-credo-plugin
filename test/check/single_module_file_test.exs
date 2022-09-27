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
  end

  describe "report an issue" do
    test "given a file has one module and one struct, reports 2 issues" do
      module_source_code = """
      defmodule SampleModuleBar do
        def print_number(number) do
        end
      end

      defstruct SampleModuleMuu do
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

    test "given a file has nested modules and struct, reports 3 issues" do
      module_source_code = """
      defmodule SampleModuleFoo do
        defmodule SampleModuleBar do
        end

        def print_number(number) do
        end
      end

      defstruct SampleModuleBaz do
      end
      """

      [issue_1, issue_2, issue_3] =
        module_source_code
        |> to_source_file()
        |> run_check(SingleModuleFile)
        |> assert_issues()

      assert issue_1.check == SingleModuleFile
      assert issue_2.check == SingleModuleFile
      assert issue_3.check == SingleModuleFile
    end
  end
end
