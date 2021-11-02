local FlyoutRow_HouseTrophies = {
  Properties = {
    Trophies = {
      default = EntityId()
    },
    TrophyIconContainer = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_HouseTrophies)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function FlyoutRow_HouseTrophies:OnInit()
  BaseElement.OnInit(self)
  self.initialHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function FlyoutRow_HouseTrophies:SetData(data)
  if not data or not data.trophyItems then
    Log("[FlyoutRow_HouseTrophies] Error: invalid data passed to SetData")
    return
  end
  local maxTrophies = 5
  local activeTrophyData = {}
  for i = 1, #data.trophyItems do
    local itemId = data.trophyItems[i]
    local item = StaticItemDataManager:GetItem(itemId)
    if item then
      table.insert(activeTrophyData, {
        icon = item.iconPath,
        staticItemData = item
      })
    end
  end
  self.Trophies:OnSetTrophyData(activeTrophyData, math.max(maxTrophies, #activeTrophyData))
  self.Trophies:SetEnabled(data.enabled)
  local height = data.height or self.initialHeight
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
end
return FlyoutRow_HouseTrophies
