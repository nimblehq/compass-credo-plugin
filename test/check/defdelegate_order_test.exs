defmodule CompassCredoPlugin.Check.DefdelegateOrderTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DefdelegateOrder

  describe "when there is any defdelegate after the first function" do
    test "reports an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        @default_value 10

        defdelegate format_number(number), to: SharedModule

        def print_number(number) do
          number
          |> format_number()
          |> inspect()
        end

        defdelegate format_text(text), to: SharedModule

        def print_text(text) do
          text
          |> format_text()
          |> inspect()
        end
      end
      """

      [issue] =
        module_source_code
        |> to_source_file()
        |> run_check(DefdelegateOrder)
        |> assert_issue()

      assert issue.check == DefdelegateOrder
    end
  end

  describe "when there is no defdelegate after the first function" do
    test "does not report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        @default_value 10

        defdelegate format_number(number), to: SharedModule
        defdelegate format_text(text), to: SharedModule

        def print_number(number) do
          number
          |> format_number()
          |> inspect()
        end

        def print_text(text) do
          text
          |> format_text()
          |> inspect()
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DefdelegateOrder)
      |> refute_issues()
    end
  end

  describe "when there is only defdelegate in the module" do
    test "does not report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        alias CredoSampleModule.AnotherModule

        @default_value 10

        defdelegate format_number(number), to: SharedModule
        defdelegate format_text(text), to: SharedModule
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DefdelegateOrder)
      |> refute_issues()
    end
  end
end
