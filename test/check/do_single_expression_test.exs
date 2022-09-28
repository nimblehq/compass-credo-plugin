defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "given valid functions, if statements and various declariations" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        my_map = %{
          a: 1
        }

        def some_function() do
           a = 5 + 7
           a + 5
        end

        def get_response(), do: {:ok, :response}

        if some_condition,
          do: :ok

        unless 1 > 2, do: :ok

        def some_other_function, do: :ok

        defp another_function(), do: :ok
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end

  describe "given all the functions and if statements are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
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

        def get_response() do
          {:ok, :response}
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 5 end)
    end
  end

  describe "given functions that contain a single expression with a do/end block BUT span multiple lines" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        def create_voucher() do
          %Voucher{}
          |> change_voucher(attrs)
          |> Repo.insert()
        end

        def get_items() do
          [
            item_1,
            item_2
          ]
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end

  describe "given a function that contains a WHEN clause and a single expression with a do/end block BUT still has a single line" do
    test "reports an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        def build_error_message(purchase, _attrs)
            when purchase.product.is_shippable == false do
          "Purchase's product is not shippable"
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issue()
    end
  end
end
