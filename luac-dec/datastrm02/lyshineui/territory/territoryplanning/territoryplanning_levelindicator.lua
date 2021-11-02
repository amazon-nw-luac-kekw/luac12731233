local TerritoryPlanning_LevelIndicator = {
  Properties = {
    LevelImage = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_LevelIndicator)
function TerritoryPlanning_LevelIndicator:OnInit()
  BaseElement.OnInit(self)
  self.imageElements = {
    self.Properties.LevelImage
  }
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function TerritoryPlanning_LevelIndicator:OnShutdown()
  if self.imageElements then
    for _, elementId in ipairs(self.imageElements) do
      if elementId ~= self.Properties.LevelImage then
        UiElementBus.Event.DestroyElement(elementId)
      end
    end
  end
end
function TerritoryPlanning_LevelIndicator:SetLevelData(currentLevel, maxLevel)
  if maxLevel < 1 then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  else
    local numElements = #self.imageElements
    if maxLevel > numElements then
      for i = numElements, maxLevel - 1 do
        local entity = CloneUiElement(self.canvasId, self.registrar, self.Properties.LevelImage, self.entityId, true)
        table.insert(self.imageElements, entity)
      end
    elseif maxLevel < numElements then
      for i = numElements, maxLevel + 1 do
        UiElementBus.Event.DestroyElement(self.imageElements[i])
        table.remove(self.imageElements, i)
      end
    end
    for i, element in ipairs(self.imageElements) do
      local isActive = i <= currentLevel
      UiImageBus.Event.SetSpritePathname(element, isActive and "LyShineUI/Images/Territory/territory_upgradedotfilled.png" or "LyShineUI/Images/Territory/territory_upgradedot.png")
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
  end
end
return TerritoryPlanning_LevelIndicator
