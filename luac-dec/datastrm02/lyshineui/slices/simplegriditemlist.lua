local SimpleGridItemList = {
  Properties = {
    Spinner = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    NoDataContainer = {
      default = EntityId()
    },
    Scrollbox = {
      default = EntityId()
    },
    Optional = {
      Dropdown = {
        default = EntityId(),
        order = 1
      },
      DropdownLabel = {
        default = EntityId(),
        order = 1
      },
      NextPageButton = {
        default = EntityId()
      },
      PrevPageButton = {
        default = EntityId()
      },
      PageNumberText = {
        default = EntityId()
      },
      HeaderText = {
        default = EntityId()
      }
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SimpleGridItemList)
function SimpleGridItemList:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.Scrollbox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.Scrollbox)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.Dropdown, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.DropdownLabel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.NextPageButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.PrevPageButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.PageNumberText, false)
end
function SimpleGridItemList:OnShutdown()
end
function SimpleGridItemList:Initialize(prototypeTable, rowTypes)
  self.prototypeTable = prototypeTable
  self.rowTypes = rowTypes
  local rowTable = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.Content, 0))
  rowTable:SetPrototypeElement(self.prototypeTable, rowTypes)
  if not rowTypes then
    self.itemsPerRow = rowTable:SetRowWidth(self.width)
  else
    self.itemsPerRowType = {}
    for i, rowType in pairs(rowTypes) do
      self.itemsPerRowType[rowType] = rowTable:GetItemsPerRow(self.width, rowType)
    end
  end
end
function SimpleGridItemList:SetHeaderText(value)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.HeaderText, true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Optional.HeaderText, value, eUiTextSet_SetLocalized)
end
function SimpleGridItemList:InitializeDropdown(dropdownData, dropdownLabel, dropdownCallbackSelf, dropdownCallbackFn)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.Dropdown, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.DropdownLabel, true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Optional.DropdownLabel, dropdownLabel, eUiTextSet_SetLocalized)
  self.Optional.Dropdown:SetWidth(400)
  self.Optional.Dropdown:SetDropdownScreenCanvasId(self.entityId)
  self.Optional.Dropdown:SetListData(dropdownData)
  self.Optional.Dropdown:SetSelectedItemData(dropdownData[1])
  if dropdownCallbackSelf then
    self.Optional.Dropdown:SetCallback(dropdownCallbackFn, dropdownCallbackSelf)
  elseif 0 < #dropdownData then
    if dropdownData[1].sortFunc == nil then
      Debug.Log("Error: SimpleGridItemList InitializeDropdown called without callbacks to handle dropdown sort functionality")
    end
    self.Optional.Dropdown:SetCallback(function(self, listItem, listItemData, dropdownTable)
      if not self.rowTypes then
        table.sort(self.listData, listItemData.sortFunc)
      else
        table.sort(self.originalListData, listItemData.sortFunc)
        self.listData = self:GetFormattedHeaderList(self.originalListData)
      end
      UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Scrollbox)
      UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.Scrollbox, 0)
    end, self)
  end
end
function SimpleGridItemList:SetPagingData(hasNextPage, hasPrevPage, pageText, pageCallbackSelf, pageCallbackFunc)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.NextPageButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.PrevPageButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Optional.PageNumberText, true)
  self.Optional.NextPageButton:SetIsClickable(hasNextPage)
  self.Optional.PrevPageButton:SetIsClickable(hasPrevPage)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Optional.PageNumberText, pageText, eUiTextSet_SetLocalized)
  local function callbackFunc(isNextPage)
    return function(pageCallbackSelf)
      pageCallbackFunc(pageCallbackSelf, isNextPage)
    end
  end
  self.Optional.NextPageButton:SetCallback(callbackFunc(true), pageCallbackSelf)
  self.Optional.PrevPageButton:SetCallback(callbackFunc(false), pageCallbackSelf)
end
function SimpleGridItemList:SetSpinnerShowing(isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoDataContainer, false)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function SimpleGridItemList:GetFormattedHeaderList(listData)
  local formattedListData = {}
  local rowTable = {}
  local forceNewRow = false
  for i = 1, #listData do
    local listItem = listData[i]
    local itemsPerRow = self.itemsPerRow or self.itemsPerRowType[listItem.rowType]
    if listItem.rowType and listItem.rowType.maxItems == 1 and 0 < #rowTable or itemsPerRow <= #rowTable or forceNewRow then
      table.insert(formattedListData, rowTable)
      rowTable = {}
      forceNewRow = false
    end
    table.insert(rowTable, listItem)
    forceNewRow = listItem.rowType and listItem.rowType.maxItems == 1
  end
  if 0 < #rowTable then
    table.insert(formattedListData, rowTable)
  end
  return formattedListData
end
function SimpleGridItemList:JumpToItem(index)
  local rowIndex
  if self.rowTypes then
    rowIndex = index
  else
    rowIndex = math.ceil(index / self.itemsPerRow)
  end
  local offset = UiDynamicScrollBoxBus.Event.GetVariableSizeElementOffset(self.Properties.Scrollbox, rowIndex - 1)
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.Scrollbox, -1 * offset)
end
function SimpleGridItemList:GetTopHeaderData()
  if self.rowTypes then
    for i = 1, #self.listData do
      local rowData = self.listData[i]
      if rowData[1].rowType.jumpable then
        local displayedElement = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.Properties.Scrollbox, i)
        if displayedElement:IsValid() then
          return rowData[1]
        end
      end
    end
  end
end
function SimpleGridItemList:OnListDataSet(listData, noDataError, skipScrollToTop)
  local newListDataSize = listData and #listData or 0
  self.listData = listData
  if self.rowTypes then
    self.originalListData = self.listData
    self.listData = self:GetFormattedHeaderList(self.listData)
  end
  self:SetSpinnerShowing(false)
  if noDataError or self:GetNumElements() == 0 then
    self.NoDataContainer:ToggleNoContractsVisibility(true, noDataError and noDataError.label or "", noDataError and noDataError.button1Data or nil, noDataError and noDataError.button2Data or nil)
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, false)
  else
    if self.Properties.NoDataContainer:IsValid() then
      self.NoDataContainer:ToggleNoContractsVisibility(false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, true)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Scrollbox)
  local orderedChildren = {}
  local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
  for i = 1, #childElements do
    local childElement = childElements[i]
    table.insert(orderedChildren, childElement)
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
  if not skipScrollToTop then
    UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.Scrollbox, 0)
  end
end
function SimpleGridItemList:GetNumElements()
  if not self.listData then
    return 0
  end
  if self.rowTypes then
    return #self.listData
  end
  return math.ceil(#self.listData / self.itemsPerRow)
end
function SimpleGridItemList:GetElementHeight(index)
  if self.listData and self.rowTypes then
    local row = self.listData[index + 1]
    if row and row[1] then
      return self.prototypeTable:GetElementHeight(row[1])
    end
  end
  return self.prototypeTable:GetElementHeight()
end
function SimpleGridItemList:OnElementBecomingVisible(rootEntity, index)
  if not self.listData then
    return
  end
  local itemRowTable = self.registrar:GetEntityTable(rootEntity)
  itemRowTable:SetPrototypeElement(self.prototypeTable)
  local itemsPerRow = itemRowTable:SetRowWidth(self.width)
  if self.rowTypes then
    local rowData = self.listData[index + 1]
    itemRowTable:OnSetDataFromGrid(rowData, 0)
  else
    itemRowTable:OnSetDataFromGrid(self.listData, index * itemsPerRow)
  end
end
function SimpleGridItemList:RequestRefreshContent()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Scrollbox)
end
return SimpleGridItemList
