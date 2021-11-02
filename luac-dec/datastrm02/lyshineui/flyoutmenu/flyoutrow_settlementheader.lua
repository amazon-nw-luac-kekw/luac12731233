local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local FlyoutRow_SettlementHeader = {
  Properties = {
    GuildNameText = {
      default = EntityId()
    },
    SettlementText = {
      default = EntityId()
    },
    GuildCrestIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_SettlementHeader)
function FlyoutRow_SettlementHeader:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
end
function FlyoutRow_SettlementHeader:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function FlyoutRow_SettlementHeader:SetData(data)
  if not data or not data.settlementKey then
    Log("[FlyoutRow_SettlementHeader] Error: invalid data passed to SetData")
    return
  end
  self.settlementKey = data.settlementKey
  if self.landClaimHandler then
    self:BusDisconnect(self.landClaimHandler)
  end
  self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementKey)
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(self.settlementKey)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementKey)
  self:UpdatePosition(posData)
  self:UpdateOwnership(ownerData)
end
function FlyoutRow_SettlementHeader:OnClaimOwnerChanged(claimKey, newOwnerData)
  if claimKey ~= self.settlementKey then
    return
  end
  self:UpdateOwnership(newOwnerData)
end
function FlyoutRow_SettlementHeader:UpdatePosition(posData)
  if posData then
    local territoryName = posData.territoryName
    if territoryName == nil or territoryName == "" then
      local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
      local tract = MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
      territoryName = "@" .. tract
    end
    UiTextBus.Event.SetTextWithFlags(self.SettlementText, territoryName, eUiTextSet_SetLocalized)
  end
end
function FlyoutRow_SettlementHeader:UpdateOwnership(ownerData)
  local guildOwner = ownerData.guildName
  if guildOwner then
    UiTextBus.Event.SetText(self.GuildNameText, guildOwner)
  end
  local guildCrestData = ownerData.guildCrestData
  if guildCrestData then
    self.GuildCrestIcon:SetSmallIcon(guildCrestData)
  end
end
return FlyoutRow_SettlementHeader
