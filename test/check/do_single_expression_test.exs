defmodule CompassCredoPlugin.Check.DoSingleExpressionTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoSingleExpression

  describe "tttt" do
    test "tt" do
      module_source_code = """
      defmodule summit do
        def create_voucher(attrs),
          do:
            [
              1,
              2
            ]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end

  describe "given all the if and unless statements are valid" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        def some_function() do
          a = 1
          if some_condition, do: :ok
        end

        def some_other_function() do
          a = 1
          unless 1 > 2, do: :ok
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end

  describe "given all the if and unless statements are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
        def some_function() do
          a = 1
          if some_condition do
            ok
          end
        end

        def some_other_function() do
          a = 1
          unless 1 > 2 do
            :ok
          end
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 2 end)
    end
  end

  describe "given all the functions are valid" do
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

        def some_other_function(),
          do: :ok

        defp another_function(), do: :ok
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> refute_issues()
    end
  end

  describe "given all the functions are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
        def some_function() do
           a = 5 + 7
        end

        def get_response() do
          {:ok, :response}
        end

        defp another_function() do
          :ok
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoSingleExpression)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 3 end)
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
