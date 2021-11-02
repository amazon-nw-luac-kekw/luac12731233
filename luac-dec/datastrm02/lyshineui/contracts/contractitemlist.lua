local ContractItemList = {
  Properties = {
    ListHeader = {
      default = EntityId()
    },
    ItemListBg = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    Mask = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    ColumnHeaderButtons = {
      Column1 = {
        default = EntityId()
      },
      Column2 = {
        default = EntityId()
      },
      Column3 = {
        default = EntityId()
      },
      Column4 = {
        default = EntityId()
      },
      Column5 = {
        default = EntityId()
      },
      Column6 = {
        default = EntityId()
      },
      Column7 = {
        default = EntityId()
      },
      Column8 = {
        default = EntityId()
      },
      Column9 = {
        default = EntityId()
      },
      Column10 = {
        default = EntityId()
      },
      Column11 = {
        default = EntityId()
      }
    },
    NoContractsContainer = {
      default = EntityId()
    },
    ScrollbarSpacing = {default = 0},
    HeaderHeight = {default = 0}
  },
  hasSelectionState = false,
  lastSelectedIndex = -1,
  listData = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractItemList)
function ContractItemList:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.entityId)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.entityId)
  local width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  if self.Properties.Mask:IsValid() and height ~= 0 then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Mask, height - self.Properties.HeaderHeight)
  end
  if width ~= 0 then
    self:SetContractItemListWidth(width)
  end
end
function ContractItemList:OnShutdown()
end
function ContractItemList:SetContractItemListWidth(width)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, width)
  if self.Properties.Mask:IsValid() then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Mask, width + self.Properties.ScrollbarSpacing)
  end
  local scrollBarWidth = 9
  if self.Properties.ListHeader:IsValid() then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ListHeader, width - scrollBarWidth)
  end
  local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
  for i = 1, #childElements do
    UiTransform2dBus.Event.SetLocalWidth(childElements[i], width - scrollBarWidth)
  end
end
function ContractItemList:SetColumnWidths(widths)
  self.widths = widths
  self.ListHeader:SetColumnWidths(widths)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
  for i = 1, #childElements do
    local contractItemTable = self.registrar:GetEntityTable(childElements[i])
    contractItemTable:SetColumnWidths(widths)
  end
end
function ContractItemList:TryGetItemData(columnData, columnIndex)
  return columnData[columnIndex] and columnData[columnIndex].text or nil
end
function ContractItemList:SetColumnHeaderData(columnData)
  self.ListHeader:SetContractItem({
    col1 = self:TryGetItemData(columnData, 1),
    col2 = self:TryGetItemData(columnData, 2),
    col3 = self:TryGetItemData(columnData, 3),
    col4 = self:TryGetItemData(columnData, 4),
    col5 = self:TryGetItemData(columnData, 5),
    col6 = self:TryGetItemData(columnData, 6),
    col7 = self:TryGetItemData(columnData, 7),
    col8 = self:TryGetItemData(columnData, 8),
    col9 = self:TryGetItemData(columnData, 9),
    col10 = self:TryGetItemData(columnData, 10),
    col11 = self:TryGetItemData(columnData, 11)
  })
  for i = 1, #columnData do
    local column = columnData[i]
    local columnButtonTable = self.ColumnHeaderButtons["Column" .. tostring(i)]
    columnButtonTable:SetIsHandlingEvents(column.callbackSelf)
    if column.callbackSelf then
      if column.startAscending ~= nil then
        if column.startAscending then
          columnButtonTable:SetSelectedAscending()
        else
          columnButtonTable:SetSelectedDescending()
        end
      end
      columnButtonTable:SetCallback(function(self, buttonTable)
        if buttonTable.direction == buttonTable.ASCENDING then
          buttonTable:SetSelectedDescending()
        else
          buttonTable:SetSelectedAscending()
        end
        local isSortAsc = buttonTable.direction == buttonTable.ASCENDING
        column.callbackFn(column.callbackSelf, isSortAsc)
        for _, otherButtonTables in pairs(self.ColumnHeaderButtons) do
          if columnButtonTable ~= otherButtonTables then
            otherButtonTables:SetDeselected()
          end
        end
      end, self)
    end
  end
end
function ContractItemList:SetSpinnerShowing(isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    UiElementBus.Event.SetIsEnabled(self.Properties.ListHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoContractsContainer, false)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function ContractItemList:OnListDataSet(listData, noContractsData)
  local newListDataSize = listData and #listData or 0
  local listSizeDelta = newListDataSize - self:GetNumElements()
  self.listData = listData
  self:SetSpinnerShowing(false)
  if noContractsData or self:GetNumElements() == 0 then
    self.NoContractsContainer:ToggleNoContractsVisibility(true, noContractsData and noContractsData.label or "", noContractsData and noContractsData.button1Data or nil, noContractsData and noContractsData.button2Data or nil)
    UiElementBus.Event.SetIsEnabled(self.Properties.ListHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, false)
    if self.Properties.ItemListBg then
      self.ScriptedEntityTweener:Set(self.Properties.ItemListBg, {h = 204})
    end
  else
    self.NoContractsContainer:ToggleNoContractsVisibility(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ListHeader, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, true)
    if self.Properties.ItemListBg then
      self.ScriptedEntityTweener:Set(self.Properties.ItemListBg, {h = 176})
    end
  end
  if 0 < listSizeDelta then
    UiDynamicScrollBoxBus.Event.AddElementsToEnd(self.entityId, listSizeDelta, false)
  elseif listSizeDelta < 0 then
    UiDynamicScrollBoxBus.Event.RemoveElementsFromFront(self.entityId, listSizeDelta)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.entityId)
  if 0 < listSizeDelta and self.widths then
    self:SetColumnWidths(self.widths)
  end
  local orderedChildren = {}
  local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
  for i = 1, #childElements do
    table.insert(orderedChildren, childElements[i])
  end
  table.sort(orderedChildren, function(a, b)
    local aPos = UiTransformBus.Event.GetLocalPositionY(a)
    local bPos = UiTransformBus.Event.GetLocalPositionY(b)
    return aPos < bPos
  end)
  for i, childElement in pairs(orderedChildren) do
    local startDelay = 0.02
    self.ScriptedEntityTweener:Play(childElement, 0.1, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = startDelay * i
    })
  end
  UiScrollBoxBus.Event.SetScrollOffsetY(self.entityId, 0)
end
function ContractItemList:SetShowSelectionState(showSelection)
  self.hasSelectionState = showSelection
  self.lastSelectedIndex = -1
end
function ContractItemList:SetContractPressedCallback(callerTable, callerFn)
  self.callerTable = callerTable
  self.callerFn = callerFn
end
function ContractItemList:GetNumElements()
  return self.listData and #self.listData or 0
end
function ContractItemList:OnElementBecomingVisible(rootEntity, index)
  if not self.listData then
    return
  end
  local listItem = self.listData[index + 1]
  local callbackData = listItem.callbackData
  local columnData = listItem.columnData
  local contractItem = self.registrar:GetEntityTable(rootEntity)
  if self.widths then
    contractItem:SetColumnWidths(self.widths)
  end
  contractItem:SetContractItem({
    col1 = columnData[1],
    col2 = columnData[2],
    col3 = columnData[3],
    col4 = columnData[4],
    col5 = columnData[5],
    col6 = columnData[6],
    col7 = columnData[7],
    col8 = columnData[8],
    col9 = columnData[9],
    col10 = columnData[10],
    col11 = columnData[11],
    itemDescriptor = listItem.itemDescriptor,
    isDisabled = listItem.isDisabled,
    disableItemBackgrounds = listItem.disableItemBackgrounds,
    isLocalPlayerCreator = listItem.isLocalPlayerCreator,
    allowCompare = listItem.allowCompare,
    perkIcons = listItem.perkIcons,
    tintColor = listItem.tintColor
  })
  if self.hasSelectionState then
    contractItem:SetSelectedVisualState(self.lastSelectedIndex == index)
  end
  if self.callerTable then
    contractItem:SetCallback(self, function(self)
      if self.hasSelectionState then
        local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
        for i = 1, #childElements do
          local contractItemTable = self.registrar:GetEntityTable(childElements[i])
          contractItemTable:SetSelectedVisualState(false)
        end
        contractItem:SetSelectedVisualState(true)
        self.lastSelectedIndex = index
      end
      self.callerFn(self.callerTable, callbackData)
    end)
  end
end
return ContractItemList
