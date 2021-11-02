function GetFlyoutMenu(dataLayer, registrar)
  local needToDeactivateDatalayer = not dataLayer
  dataLayer = dataLayer or RequireScript("LyShineUI.UiDataLayer")
  local dataNode = dataLayer:GetDataNode("Hud.FlyoutMenu.EntityId")
  if dataNode then
    if needToDeactivateDatalayer then
    end
    registrar = registrar or RequireScript("LyShineUI.EntityRegistrar")
    return registrar:GetEntityTable(dataNode:GetData())
  end
  if needToDeactivateDatalayer then
  end
  return nil
end
