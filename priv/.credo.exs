%{
  configs: [
    %{
      name: "default",
      checks: [
        {CompassCredoPlugin.Check.DefdelegateOrder, []},
        {CompassCredoPlugin.Check.RepeatingFragments, []},
      ]
    }
  ]
}
