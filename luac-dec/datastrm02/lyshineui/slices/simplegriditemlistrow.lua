local SimpleGridItemListRow = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SimpleGridItemListRow)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(SimpleGridItemListRow)
function SimpleGridItemListRow:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function SimpleGridItemListRow:OnShutdown()
end
function SimpleGridItemListRow:SetPrototypeElement(entityTable, rowTypes)
  if not entityTable then
    Debug.Log("SimpleGridItemListRow.PrototypeElement was nil")
  end
  self.rowTypes = rowTypes
  if self.PrototypeElement ~= entityTable then
    self.PrototypeElement = entityTable
    if type(self.PrototypeElement) ~= "table" then
      Debug.Log("SimpleGridItemListRow.PrototypeElement must have a script")
    end
    if self.PrototypeElement.SetGridItemData == nil then
      Debug.Log("SimpleGridItemListRow.PrototypeElement must implement SetGridItemData")
    end
    if self.PrototypeElement.GetElementWidth == nil then
      Debug.Log("SimpleGridItemListRow.PrototypeElement must implement GetElementWidth")
    end
    if self.PrototypeElement.GetElementHeight == nil then
      Debug.Log("SimpleGridItemListRow.PrototypeElement must implement GetElementHeight")
    end
    if self.PrototypeElement.GetHorizontalSpacing == nil then
      Debug.Log("SimpleGridItemListRow.PrototypeElement must implement GetHorizontalSpacing")
    end
    self.elementWidth = self.PrototypeElement:GetElementWidth()
    local elementHeight = self.PrototypeElement:GetElementHeight()
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, elementHeight)
    local elementSpacing = self.PrototypeElement:GetHorizontalSpacing()
    UiLayoutRowBus.Event.SetSpacing(self.entityId, elementSpacing)
    self.gridItemElements = {}
  end
end
function SimpleGridItemListRow:GetItemsPerRow(rowWidth, rowType)
  local elementWidth = self.PrototypeElement:GetElementWidth(rowType)
  local spacing = UiLayoutRowBus.Event.GetSpacing(self.entityId)
  local elementsNeeded = math.floor((rowWidth + spacing) / (elementWidth + spacing))
  return math.min(rowType.maxItems, math.max(1, elementsNeeded))
end
function SimpleGridItemListRow:SetRowWidth(rowWidth, rowType)
  self.rowType = rowType
  local elementWidth = self.elementWidth
  if rowType then
    elementWidth = self.PrototypeElement:GetElementWidth(rowType)
  end
  local spacing = UiLayoutRowBus.Event.GetSpacing(self.entityId)
  local elementsNeeded = math.floor((rowWidth + spacing) / (self.elementWidth + spacing))
  if elementsNeeded < #self.gridItemElements then
    for i = elementsNeeded + 1, #self.gridItemElements do
      local element = self.gridItemElements[i]
      UiElementBus.Event.DestroyElement(element)
      self.gridItemElements[i] = nil
    end
  elseif elementsNeeded > #self.gridItemElements then
    for i = 1, elementsNeeded - #self.gridItemElements do
      local newElement = CloneUiElement(self.canvasId, self.registrar, self.PrototypeElement.entityId, self.entityId, true)
      table.insert(self.gridItemElements, newElement)
    end
  end
  return elementsNeeded
end
function SimpleGridItemListRow:OnSetDataFromGrid(listData, startIndex)
  local maxListData = #listData
  for i = 1, #self.gridItemElements do
    local data
    local listDataIndex = startIndex + i
    if maxListData >= listDataIndex then
      data = listData[listDataIndex]
    end
    local elementToSetup = self.gridItemElements[i]
    elementToSetup:SetGridItemData(data)
  end
end
return SimpleGridItemListRow
