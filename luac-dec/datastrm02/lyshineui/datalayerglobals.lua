local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local DataLayerGlobals = {}
function DataLayerGlobals:Activate()
  dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging.ContainerType")
  dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging.ContainerId")
  dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging.ContainerSlotId")
  dataLayer:GetDataNode("Hud.LocalPlayer.ItemDragging.StackSize")
end
return DataLayerGlobals
