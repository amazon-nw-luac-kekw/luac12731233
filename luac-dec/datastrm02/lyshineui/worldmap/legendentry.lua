local LegendEntry = {
  Properties = {
    IconContainer = {
      default = EntityId()
    }
  },
  itemLayoutSlicePath = "LyShineUI\\Slices\\ItemLayoutSimple"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LegendEntry)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(LegendEntry)
function LegendEntry:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.IconContainer)
end
function LegendEntry:SetLegendEntryItems(itemIds)
  if not itemIds then
    return
  end
  for i = 1, #itemIds do
    self:SpawnSlice(self.IconContainer, self.itemLayoutSlicePath, self.OnIconSpawned, {
      itemId = itemIds[i]
    })
  end
end
function LegendEntry:OnIconSpawned(entity, data)
  local itemId = data.itemId
  entity:SetItemByName(itemId, "")
  entity:SetTooltipEnabled(true)
  UiLayoutCellBus.Event.SetTargetWidth(entity.entityId, entity.mWidth)
end
return LegendEntry
