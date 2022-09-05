%{
  configs: [
    %{
      name: "default",
      checks: [
        {CompassCredoPlugin.Checks.DefdelegateOrder, []}
      ]
    }
  ]
}
