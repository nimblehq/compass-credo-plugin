%{
  configs: [
    %{
      name: "default",
      checks: [
        {CompassCredoPlugin.Check.DefdelegateOrder, []}
      ]
    }
  ]
}
