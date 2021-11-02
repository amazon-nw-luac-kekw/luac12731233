local SimpleTreeList = {
  Properties = {
    ScrollBox = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SimpleTreeList)
function SimpleTreeList:OnInit()
  BaseElement.OnInit(self)
  self.lastCollapsedParent = 0
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ScrollBox)
end
function SimpleTreeList:OnDataSet(idAndTreeDataList, treeStructure, onLeafClickedCallback, onLeafClickedCallbackTable, skipScrollToTop)
  self.idAndTreeDataList = idAndTreeDataList
  self.treeStructure = treeStructure
  self.onLeafClickedCallback = onLeafClickedCallback
  self.onLeafClickedCallbackTable = onLeafClickedCallbackTable
  self.lastSelectedId = self.treeStructure and self.treeStructure[1].id or nil
  self:RebuildStructureList()
  if not skipScrollToTop then
    UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ScrollBox, 0)
  end
end
function SimpleTreeList:RebuildStructureList()
  self.flattenedtreeStructure = {}
  local treeStructureSize = self.treeStructure and #self.treeStructure or 0
  for i = 1, treeStructureSize do
    local currentData = self.treeStructure[i]
    if currentData ~= nil then
      table.insert(self.flattenedtreeStructure, currentData.id)
      if self.idAndTreeDataList[currentData.id].expanded then
        local indexKey = 1
        local accessedItems = 0
        local totalItems = CountAssociativeTable(currentData.children)
        while accessedItems < totalItems do
          local currentChild = currentData.children[indexKey]
          if currentChild ~= nil then
            accessedItems = accessedItems + 1
            self.idAndTreeDataList[currentChild.id].indexKey = indexKey
            table.insert(self.flattenedtreeStructure, currentChild.id)
          end
          indexKey = indexKey + 1
        end
      end
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Content, true)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function SimpleTreeList:OnClickedElement(id)
  local data = self.idAndTreeDataList[id]
  if data.hasChildren then
    local expanded = data.expanded
    if expanded then
      local treeStructureCount = self.treeStructure and #self.treeStructure or 0
      for i = 1, treeStructureCount do
        local currentElement = self.treeStructure[i]
        if currentElement ~= nil and currentElement.id == id then
          local children = currentElement.children
          for k, v in pairs(children) do
            if v ~= nil and v.id == self.lastSelectedId then
              data.selected = true
              self.lastCollapsedParent = id
            end
          end
        end
      end
    else
      if self.lastCollapsedParent == id then
        self.lastCollapsedParent = 0
      end
      data.selected = false
    end
    data.expanded = not expanded
  else
    self.onLeafClickedCallback(self.onLeafClickedCallbackTable, id)
    if self.lastCollapsedParent ~= 0 then
      self.idAndTreeDataList[self.lastCollapsedParent].selected = false
      self.lastCollapsedParent = 0
    end
    self.idAndTreeDataList[self.lastSelectedId].selected = false
    self.lastSelectedId = id
    data.selected = true
  end
  self:RebuildStructureList()
end
function SimpleTreeList:GetNumElements()
  return self.flattenedtreeStructure and #self.flattenedtreeStructure or 0
end
function SimpleTreeList:OnElementBecomingVisible(rootEntity, index)
  if not self.flattenedtreeStructure then
    return
  end
  local rowTable = self.registrar:GetEntityTable(rootEntity)
  local id = self.flattenedtreeStructure[index + 1]
  local data = self.idAndTreeDataList[id]
  rowTable:SetTreeRowData(id, self.idAndTreeDataList[id], self.OnClickedElement, self)
end
return SimpleTreeList
