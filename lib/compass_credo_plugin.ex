defmodule CompassCredoPlugin do
  @config_file :code.priv_dir(:compass_credo_plugin)
               |> Path.join(".credo.exs")
               |> File.read!()

  import Credo.Plugin

  def init(exec) do
    register_default_config(exec, @config_file)
  end
end
