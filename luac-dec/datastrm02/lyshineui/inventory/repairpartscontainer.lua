local RepairPartsContainer = {
  Properties = {
    Container = {
      default = EntityId()
    },
    Tier1 = {
      default = EntityId()
    }
  },
  hasInitialData = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairPartsContainer)
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
function RepairPartsContainer:OnInit()
  BaseElement.OnInit(self)
  self.tierEntities = {
    [InventoryCommon:GetRepairPartId(1)] = self.Tier1
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-repair-parts", function(self, enableRepairParts)
    if enableRepairParts ~= nil then
      self.enableRepairParts = enableRepairParts
      self:SetInitialData()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
      self:SetInitialData()
    end
  end)
end
function RepairPartsContainer:SetInitialData()
  if not self.enableRepairParts then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  if not self.hasInitialData and self.playerEntityId then
    self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
    local repairPartId = InventoryCommon:GetRepairPartId(1)
    self.Tier1:SetValue(CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, repairPartId))
    self.Tier1:SetMaxValue(CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.playerEntityId, repairPartId))
    self.hasInitialData = true
  end
end
function RepairPartsContainer:SetVisibilityCallback(command, table)
  self.visibilityCallback = command
  self.visibilityCallbackTable = table
  if self.hasInitialData and command and table then
    local skipLineAnimation = true
    command(table, self.isVisible, skipLineAnimation)
  end
end
function RepairPartsContainer:OnCategoricalProgressionPointsChanged(progressionId, oldPoints, newPoints)
  local tierEntity = self.tierEntities[progressionId]
  if tierEntity then
    tierEntity:SetValue(newPoints)
  end
end
function RepairPartsContainer:OnCategoricalProgressionRankChanged(progressionId, oldRank, newRank)
  local tierEntity = self.tierEntities[progressionId]
  if tierEntity then
    tierEntity:SetMaxValue(CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(data, progressionId))
  end
end
function RepairPartsContainer:GetRepairPartsContainerHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.Properties.Container)
end
function RepairPartsContainer:GetTierButtonPosition(tier)
  local buttonEntityId = self.Properties["Tier" .. tier]
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(buttonEntityId)
  return Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - buttonRect:GetHeight() / 2)
end
return RepairPartsContainer
