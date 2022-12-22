defmodule CompassCredoPlugin.Check.DoBlockHasMultipleLinesTest do
  use Credo.Test.Case

  alias CompassCredoPlugin.Check.DoBlockHasMultipleLines

  describe "given all the do: functions are valid" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        def validate_coupon(), do: :ok

        def list_by_ids(courier_company_ids),
          do: where(CourierCompany, [company], company.id in ^courier_company_ids)

        def build_error_message(purchase, _attrs)
          when purchase.product.is_shippable == false,
          do: "Purchase's product is not shippable"

        def create_voucher(attrs),
         do: [1, 2, 3]

         def create_voucher(attrs),
          do:
            %Voucher{}
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> refute_issues()
    end
  end

  describe "given all the do: functions are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do

        def create_voucher(attrs),
          do:
            %Voucher{}
            |> change_voucher(attrs)

        def create_voucher(attrs), do: [
          1
        ]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 2 end)
    end
  end

  describe "given all the do: private functions are valid" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        defp validate_coupon(), do: :ok

        defp list_by_ids(courier_company_ids),
          do: where(CourierCompany, [company], company.id in ^courier_company_ids)

        defp build_error_message(purchase, _attrs)
          when purchase.product.is_shippable == false,
          do: "Purchase's product is not shippable"

        defp create_voucher(attrs),
         do: [1, 2, 3]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> refute_issues()
    end
  end

  describe "given all the do: private functions are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do

        defp create_voucher(attrs),
          do:
            %Voucher{}
            |> change_voucher(attrs)
            |> Repo.insert()

        defp create_voucher(attrs), do: [
          1,
          2,
          3
        ]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 2 end)
    end
  end

  describe "given all the if: expressions are valid" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        if true, do: :ok

        if true,
          do: :ok

        if true,
          do:
            :ok

        if true,
          do:
            %Voucher{},
          else:
            :ok
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> refute_issues()
    end
  end

  describe "given all the if: expressions are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
        if true,
          do:
            %Voucher{}
            |> Repo.insert()

        if true, do: [
          1,
        ]

        if true,
          do:
            %Voucher{}
            |> Repo.insert(),
          else:
            :ok
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 3 end)
    end
  end

  describe "given all the unless: expressions are valid" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        unless true, do: :ok

        unless true,
          do: :ok

        unless true,
          do:
            :ok
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> refute_issues()
    end
  end

  describe "given all the unless: expressions are INVALID" do
    test "reports an issue on all instances" do
      module_source_code = """
      defmodule CredoSampleModule do
        unless true,
          do:
            %Voucher{}
            |> Repo.insert()

        unless true, do: [
          1,
        ]
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> assert_issues(fn issues -> assert Enum.count(issues) == 2 end)
    end
  end

  describe "given all the functions contain do and end blocks" do
    test "does NOT report an issue" do
      module_source_code = """
      defmodule CredoSampleModule do
        def some_function() do
           [
            1
           ]
        end

        def another_function() do
          %Voucher{}
            |> change_voucher(attrs)
            |> Repo.insert()
        end
      end
      """

      module_source_code
      |> to_source_file()
      |> run_check(DoBlockHasMultipleLines)
      |> refute_issues()
    end
  end
end
