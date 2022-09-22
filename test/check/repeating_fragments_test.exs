defmodule CompassCredoPlugin.Check.RepeatingFragmentsTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.RepeatingFragments

  describe "when there repeating fragments in module names and namespaces" do
    test "reports an issue" do
      module_source_codes = [
        # simple case
        """
          defmodule Todo.Todo do
            alias CredoSampleModule.AnotherModule

            def method, do: :ok
          end
        """,
        # more advanced case
        """
          defmodule Todo.Something.Else.Todo do
            alias CredoSampleModule.AnotherModule

            def method, do: :ok
          end
        """
      ]

      Enum.each(module_source_codes, fn module_source_code ->
        [issue] =
          module_source_code
          |> to_source_file()
          |> run_check(RepeatingFragments)
          |> assert_issue()

        assert issue.check == RepeatingFragments
      end)
    end
  end

  describe "when there aren't repeating fragments in module names and namespaces" do
    test "does not report an issue" do
      module_source_code = """
        defmodule Todo.Item do
          alias CredoSampleModule.AnotherModule

          def method, do: :ok
        end
      """

      module_source_code
      |> to_source_file()
      |> run_check(RepeatingFragments)
      |> refute_issues()
    end
  end

  describe "when there aren't module name" do
    test "does not report an issue" do
      module_source_code = """
        name = "abc"
      """

      module_source_code
      |> to_source_file()
      |> run_check(RepeatingFragments)
      |> refute_issues()
    end
  end
end
