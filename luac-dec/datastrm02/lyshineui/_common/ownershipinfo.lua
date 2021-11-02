local OwnershipInfo = {
  Properties = {
    Label = {
      default = EntityId()
    },
    Owner = {
      default = EntityId()
    },
    SecurityLevelLabel = {
      default = EntityId()
    }
  },
  guildId = GuildId()
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OwnershipInfo)
function OwnershipInfo:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
    self.guildId = guildId
    self:OnOwnershipChanged(self.ownershipData)
  end)
  self.guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  UiTextBus.Event.SetText(self.Properties.Label, "@ui_owned_by")
  self.ownershipData = UiOwnership()
end
function OwnershipInfo:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function OwnershipInfo:OnOwnershipChanged(ownership)
  self.ownershipData.ownedByName = ownership.ownedByName
  self.ownershipData.ownedByGuildId = ownership.ownedByGuildId
  self.ownershipData.ownershipSecurityLevel = ownership.ownershipSecurityLevel
  UiTextBus.Event.SetText(self.Properties.Owner, ownership.ownedByName)
  local securityLevelApplies = tonumber(self.ownershipData.ownershipSecurityLevel) > 0
  local isMyGuild = ownership.ownedByGuildId == self.guildId
  local showSecurityText = isMyGuild and securityLevelApplies
  UiElementBus.Event.SetIsEnabled(self.Properties.SecurityLevelLabel, showSecurityText)
  if showSecurityText then
    local securityText = GuildsComponentBus.Broadcast.GetRankNameForSecurityLevel(ownership.ownershipSecurityLevel) .. "_and_above"
    UiTextBus.Event.SetTextWithFlags(self.Properties.SecurityLevelLabel, "<img src=\"lyshineui/images/markers/marker_textDivider\" xPadding=\"0\" scale=\"1\" yOffset=\"0\" />" .. "  " .. securityText, eUiTextSet_SetLocalized)
  end
end
return OwnershipInfo
