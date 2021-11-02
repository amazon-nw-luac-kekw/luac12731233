local WarDeclarationPopupHelper = {}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function WarDeclarationPopupHelper:ShowWarDeclarationPopup(guildId, guildName, guildCrestData, territoryId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.WarDeclarationPopup.GuildId", guildId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.WarDeclarationPopup.GuildName", guildName)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.WarDeclarationPopup.GuildCrest", guildCrestData)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.WarDeclarationPopup.TerritoryId", territoryId)
  dataLayer:SetScreenEnabled("WarDeclarationPopup", true)
end
return WarDeclarationPopupHelper
