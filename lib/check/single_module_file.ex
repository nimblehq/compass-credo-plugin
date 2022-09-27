defmodule CompassCredoPlugin.Check.SingleModuleFile do
  use Credo.Check,
    base_priority: :high,
    category: :refactor,
    explanations: [
      check: """
        Prefer one module per source file.

        # lib/account/user.ex
        defmodule App.Accounts.User do
          defmodule App.Accounts.SuperUser do
            defstruct name: "John", age: 27
          end

          # ...
        end

        # lib/account/user.ex
        defmodule App.Accounts.User do
          # ...
        end

        # lib/account/super_user.ex
        defmodule App.Accounts.SuperUser do
          defstruct name: "John", age: 27

          # ...
        end
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    issues =
      source_file
      |> Credo.Code.to_tokens()
      |> Enum.filter(fn line ->
        case line do
          {:identifier, _meta, :defmodule} -> true
          _ -> false
        end
      end)
      |> Enum.reduce([], fn item, acc ->
        case item do
          {:identifier, {line, _columns, _}, _} ->
            [issue_for(issue_meta, line, "") | acc]
        end
      end)

    if Enum.count(issues) > 1 do
      issues
    else
      []
    end
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "Prefer one module per source file.",
      line_no: line_no,
      trigger: trigger
    )
  end
end
