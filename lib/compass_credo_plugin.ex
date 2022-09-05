defmodule CompassCredoPlugin do
  import Credo.Plugin

  @config_file :compass_credo_plugin
               |> :code.priv_dir()
               |> Path.join(".credo.exs")
               |> File.read!()

  def init(exec) do
    register_default_config(exec, @config_file)
  end
end
