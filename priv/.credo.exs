%{
  configs: [
    %{
      name: "default",
      checks: [
        {CompassCredoPlugin.Check.DefdelegateOrder, []},
        {CompassCredoPlugin.Check.SingleModuleFile, []},
        {CompassCredoPlugin.Check.RepeatingFragments, []}
        {CompassCredoPlugin.Check.DoEndBlockHasSingleLine, []},
        {CompassCredoPlugin.Check.DoBlockHasMultipleLines, []},
      ]
    }
  ]
}
