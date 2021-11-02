local TextInputSearch = {
  Properties = {
    ClearFieldButton = {
      default = EntityId()
    },
    SearchbarBackground = {
      default = EntityId()
    },
    SearchbarFrame = {
      default = EntityId()
    },
    ResultList = {
      default = EntityId()
    },
    ResultListContents = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    ResultHeaderText = {
      default = EntityId()
    },
    ResultDivider = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  },
  matchingList = {},
  requestDelay = 0,
  timer = 0,
  maxResults = 100,
  maxStringLength = 50,
  isSpinning = false,
  listItemHeight = 34,
  listItemSlice = "LyShineUI\\Slices\\TextInputSearchListItemNCB",
  selectedCallback = nil,
  selectedTable = nil,
  enterCallback = nil,
  enterTable = nil,
  startEditCallback = nil,
  startEditTable = nil,
  endEditCallback = nil,
  endEditTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TextInputSearch)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(TextInputSearch)
local LocalizedItemSearch = RequireScript("LyShineUI.Contracts.LocalizedItemSearch")
function TextInputSearch:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiTextInputNotificationBus, self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.DisabledContainer)
  self:SetMaxStringLength(self.maxStringLength)
  local numCategories = #ItemDataManagerBus.Broadcast.GetFilteredCategoryList("", "", "", "")
  local numSlicesToSpawn = self.maxResults + numCategories
  for i = 1, numSlicesToSpawn do
    self:SpawnSlice(self.DisabledContainer, self.listItemSlice, self.OnListItemSpawn)
  end
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, false)
  self.ScriptedEntityTweener:Set(self.Spinner, {rotation = 0, opacity = 0})
  UiTextBus.Event.SetColor(self.ResultHeaderText, self.UIStyle.COLOR_TAN)
  UiImageBus.Event.SetColor(self.ResultDivider, self.UIStyle.COLOR_TAN)
  self.spacing = UiLayoutColumnBus.Event.GetSpacing(self.ResultListContents)
end
function TextInputSearch:OnShutdown()
end
function TextInputSearch:SetText(text)
  UiTextInputBus.Event.SetText(self.entityId, text)
end
function TextInputSearch:GetText()
  return UiTextInputBus.Event.GetText(self.entityId)
end
function TextInputSearch:SetMaxStringLength(value)
  UiTextInputBus.Event.SetMaxStringLength(self.entityId, value)
end
function TextInputSearch:GetMaxStringLength()
  return UiTextInputBus.Event.GetMaxStringLength(self.entityId)
end
function TextInputSearch:SetSelectedCallback(command, table)
  self.selectedCallback = command
  self.selectedTable = table
end
function TextInputSearch:SetEnterCallback(command, table)
  self.enterCallback = command
  self.enterTable = table
end
function TextInputSearch:SetStartEditCallback(command, table)
  self.startEditCallback = command
  self.startEditTable = table
end
function TextInputSearch:SetEndEditCallback(command, table)
  self.endEditCallback = command
  self.endEditTable = table
end
function TextInputSearch:SetActiveAndBegin()
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.entityId, true)
  UiTextInputBus.Event.BeginEdit(self.entityId)
end
function TextInputSearch:OnListItemSpawn(entity, data)
  entity:SetCallback(self.OnItemSelected, self)
end
function TextInputSearch:StartSpinner()
  if self.Spinner:IsValid() and not self.isSpinning then
    self.ScriptedEntityTweener:Play(self.Spinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isSpinning = true
  end
end
function TextInputSearch:StopSpinner()
  if self.Spinner:IsValid() and self.isSpinning then
    self.ScriptedEntityTweener:Stop(self.Spinner)
    self.ScriptedEntityTweener:Set(self.Spinner, {rotation = 0, opacity = 0})
    self.isSpinning = false
  end
end
function TextInputSearch:StartTick()
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function TextInputSearch:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function TextInputSearch:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer > self.requestDelay then
    self:UpdateItemList()
    self:StopTick()
  end
end
function TextInputSearch:SetSearchOverride(searchFn, searchFnSelf)
  self.searchFn = searchFn
  self.searchFnSelf = searchFnSelf
  self.skipCategoryUpdate = true
end
function TextInputSearch:UpdateItemList()
  if not self.skipCategoryUpdate then
    self.matchingList = {}
  end
  local items
  if not self.searchFn then
    items = LocalizedItemSearch:Search(self.currentText, true)
  else
    items = self.searchFn(self.searchFnSelf, self.currentText)
  end
  local numResults = math.min(#items, self.maxResults)
  if self.skipCategoryUpdate then
    for _, itemData in ipairs(items) do
      local listItem = self:GetAvailableListItem()
      if listItem then
        listItem:SetItemData(itemData, true)
      end
    end
  else
    for i = 1, numResults do
      if not self.matchingList[items[i].category] then
        self.matchingList[items[i].category] = {}
      end
      table.insert(self.matchingList[items[i].category], items[i])
    end
    for category, items in pairs(self.matchingList) do
      local listItem = self:GetAvailableListItem()
      if listItem then
        listItem:SetCategory(category)
      end
      for _, itemData in ipairs(items) do
        listItem = self:GetAvailableListItem()
        if listItem then
          listItem:SetItemData(itemData, true)
        end
      end
    end
  end
  UiElementBus.Event.SetIsEnabled(self.ResultList, 0 < numResults)
  self:StopSpinner()
end
function TextInputSearch:GetAvailableListItem()
  local childId = UiElementBus.Event.GetChild(self.DisabledContainer, 0)
  if childId:IsValid() then
    local listItem = self.registrar:GetEntityTable(childId)
    if listItem then
      UiElementBus.Event.Reparent(childId, self.ResultListContents, EntityId())
      return listItem
    end
  end
  return nil
end
function TextInputSearch:OnItemSelected(itemData)
  self:ClearMatchingList()
  UiTextInputBus.Event.SetText(self.entityId, "")
  self:ExecuteCallback(self.selectedCallback, self.selectedTable, itemData)
end
function TextInputSearch:OnTextInputChange(textString)
  textString = textString or ""
  if textString == self.currentText then
    return
  end
  self.currentText = textString
  local stringLength = string.len(textString)
  if 0 < stringLength then
    self.timer = 0
    self:StartSpinner()
    self:StartTick()
    self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 1})
    UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, true)
  else
    self:StopSpinner()
    self:StopTick()
    self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, false)
  end
  self:ClearMatchingList()
end
function TextInputSearch:ExecuteCallback(command, table, data)
  if command ~= nil and table ~= nil then
    if type(command) == "function" then
      command(table, data)
    elseif type(table[command]) == "function" then
      table[command](table, data)
    end
  end
end
function TextInputSearch:ClearMatchingList()
  local childElements = UiElementBus.Event.GetChildren(self.ResultListContents)
  for i = 2, #childElements do
    UiElementBus.Event.Reparent(childElements[i], self.DisabledContainer, EntityId())
  end
  UiElementBus.Event.SetIsEnabled(self.ResultList, false)
end
function TextInputSearch:OnHoverSearchBar()
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.15, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SearchbarFrame, 0.15, {opacity = 1, ease = "QuadOut"})
end
function TextInputSearch:OnUnhoverSearchBar()
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.15, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SearchbarFrame, 0.15, {opacity = 0.7, ease = "QuadOut"})
end
function TextInputSearch:OnStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.3, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SearchbarFrame, 0.15, {opacity = 1, ease = "QuadOut"})
  self:ExecuteCallback(self.startEditCallback, self.startEditTable)
end
function TextInputSearch:OnEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.3, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.SearchbarFrame, 0.15, {opacity = 0.7, ease = "QuadOut"})
  self:ExecuteCallback(self.endEditCallback, self.endEditTable)
end
function TextInputSearch:OnEnter()
  self:ExecuteCallback(self.enterCallback, self.enterTable)
end
function TextInputSearch:ClearSearchField()
  UiTextInputBus.Event.SetText(self.entityId, "")
  self:StopSpinner()
  self:StopTick()
  self:ClearMatchingList()
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, false)
end
return TextInputSearch
