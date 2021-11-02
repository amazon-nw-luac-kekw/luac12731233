local InlineTextSuggestions = {
  Properties = {
    ResultList = {
      default = EntityId()
    },
    ResultListContents = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  },
  matchingList = {},
  requestDelay = 0,
  timer = 0,
  maxResults = 10,
  isSpinning = false,
  listItemHeight = 34,
  listItemSlice = "LyShineUI\\Slices\\TextInputSearchListItem",
  positionOffset = {x = 0, y = -24},
  selectedCallback = nil,
  selectedTable = nil
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(InlineTextSuggestions)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(InlineTextSuggestions)
function InlineTextSuggestions:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.DisabledContainer)
  local numSlicesToSpawn = self.maxResults
  for i = 1, numSlicesToSpawn do
    self:SpawnSlice(self.DisabledContainer, self.listItemSlice, self.OnListItemSpawn)
  end
  self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
  self.spacing = UiLayoutColumnBus.Event.GetSpacing(self.ResultListContents)
  self.defaultHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  DynamicBus.InlineTextSuggestions.Connect(self.entityId, self)
end
function InlineTextSuggestions:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.InlineTextSuggestions.Disconnect(self.entityId, self)
end
function InlineTextSuggestions:RequestSuggestions(searchList, textInput, callbackSelf, callbackFunction, drawPosition, drawOrder, startDeliminator)
  self.searchList = searchList
  self.textInput = textInput
  self.textInputHandler = self:BusConnect(UiTextInputNotificationBus, textInput)
  self.startDeliminator = startDeliminator or 0
  self.selectedCallback = callbackFunction
  self.selectedTable = callbackSelf
  drawPosition = drawPosition or UiTransformBus.Event.GetViewportPosition(textInput)
  drawPosition.x = drawPosition.x + self.positionOffset.x
  drawPosition.y = drawPosition.y + self.positionOffset.y
  UiTransformBus.Event.SetViewportPosition(self.entityId, drawPosition)
  if not self.defaultDrawOrder then
    self.defaultDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  end
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, drawOrder or self.defaultDrawOrder)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.defaultHeight)
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  self:UpdateMatchingList()
end
function InlineTextSuggestions:StopSuggestions()
  if UiCanvasBus.Event.GetEnabled(self.canvasId) then
    self:StopSpinner()
    self:StopTick()
    self:ClearMatchingList()
    if self.textInputHandler then
      self:BusDisconnect(self.textInputHandler)
      self.textInputHandler = nil
    end
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.defaultDrawOrder)
  end
end
function InlineTextSuggestions:OnListItemSpawn(entity, data)
  entity:SetCallback(self.OnItemSelected, self)
end
function InlineTextSuggestions:StartSpinner()
  if self.Properties.Spinner:IsValid() and not self.isSpinning then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isSpinning = true
  end
end
function InlineTextSuggestions:StopSpinner()
  if self.Properties.Spinner:IsValid() and self.isSpinning then
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
    self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
    self.isSpinning = false
  end
end
function InlineTextSuggestions:StartTick()
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function InlineTextSuggestions:StopTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function InlineTextSuggestions:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer > self.requestDelay then
    self:UpdateMatchingList()
    self:StopTick()
  end
end
function InlineTextSuggestions:StringStartsWith(str, start)
  return str:sub(1, #start) == start
end
function InlineTextSuggestions:UpdateMatchingList()
  if self.currentText == nil then
    self.currentText = ""
  end
  self.matchingList = {}
  local numResults = 0
  for _, entry in ipairs(self.searchList) do
    local toCompare = entry.toCompare or entry.displayName
    local isMatch = self.currentText == "" or self:StringStartsWith(toCompare:lower(), self.currentText:lower())
    if isMatch then
      table.insert(self.matchingList, entry)
      numResults = numResults + 1
      if numResults >= self.maxResults then
        break
      end
    end
  end
  for _, item in ipairs(self.matchingList) do
    local listItem = self:GetAvailableListItem()
    if listItem then
      listItem:SetItemData(item)
      if not self.itemHeight then
        self.itemHeight = UiLayoutCellBus.Event.GetTargetHeight(listItem.entityId)
      end
    end
  end
  UiElementBus.Event.SetIsEnabled(self.ResultList, 0 < numResults)
  if 0 < numResults then
    self:SetHighlightedIndex(0, false)
  end
  local height = 0
  if 0 < numResults and self.itemHeight then
    height = self.itemHeight * numResults
  end
  UiTransform2dBus.Event.SetLocalHeight(self.ResultList, height)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  self:StopSpinner()
end
function InlineTextSuggestions:GetAvailableListItem()
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
function InlineTextSuggestions:OnItemSelected(itemData)
  self:ExecuteCallback(self.selectedCallback, self.selectedTable, itemData)
  self:StopSuggestions()
end
function InlineTextSuggestions:ExecuteCallback(command, table, data)
  if command ~= nil and table ~= nil then
    command(table, data)
  end
end
function InlineTextSuggestions:ClearMatchingList()
  local childElements = UiElementBus.Event.GetChildren(self.ResultListContents)
  for i = 1, #childElements do
    UiElementBus.Event.Reparent(childElements[i], self.DisabledContainer, EntityId())
  end
  UiElementBus.Event.SetIsEnabled(self.ResultList, false)
  self.highlightedIndex = nil
end
function InlineTextSuggestions:SetHighlightedIndex(index, wrap)
  if self.highlightedIndex then
    local oldEntityId = UiElementBus.Event.GetChild(self.Properties.ResultListContents, self.highlightedIndex)
    if oldEntityId:IsValid() then
      local oldEntityTable = self.registrar:GetEntityTable(oldEntityId)
      oldEntityTable:OnUnfocus()
    end
  end
  if wrap then
    local numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.ResultListContents)
    if index < 0 then
      index = numChildren + index
    elseif numChildren <= index then
      index = index - numChildren
    end
  end
  local newEntityId = UiElementBus.Event.GetChild(self.Properties.ResultListContents, index)
  if newEntityId:IsValid() then
    local newEntityTable = self.registrar:GetEntityTable(newEntityId)
    newEntityTable:OnFocus()
  end
  self.highlightedIndex = index
end
function InlineTextSuggestions:HighlightNext()
  self:SetHighlightedIndex(self.highlightedIndex ~= nil and self.highlightedIndex + 1 or 0, true)
end
function InlineTextSuggestions:HighlightPrevious()
  self:SetHighlightedIndex(self.highlightedIndex ~= nil and self.highlightedIndex - 1 or -1, true)
end
function InlineTextSuggestions:OnUpArrow()
  self:HighlightNext()
end
function InlineTextSuggestions:OnDownArrow()
  self:HighlightPrevious()
end
function InlineTextSuggestions:OnTextInputChange(textString)
  if textString == self.currentText then
    return
  end
  if self.startDeliminator then
    local startStrIndex = string.find(textString, self.startDeliminator .. "[^" .. self.startDeliminator .. "]*$")
    self.currentText = startStrIndex and textString:sub(startStrIndex + self.startDeliminator:len()) or ""
  else
    self.currentText = textString
  end
  local stringLength = string.len(textString)
  if 0 < stringLength then
    self.timer = 0
    self:StartSpinner()
    self:StartTick()
  else
    self:StopSpinner()
    self:StopTick()
  end
  self:ClearMatchingList()
end
function InlineTextSuggestions:OnTextInputEnter()
  if not self.highlightedIndex then
    self:HighlightNext()
  end
  if self.highlightedIndex then
    local selectedItemId = UiElementBus.Event.GetChild(self.Properties.ResultListContents, self.highlightedIndex)
    if selectedItemId:IsValid() then
      local selectedItemTable = self.registrar:GetEntityTable(selectedItemId)
      selectedItemTable:OnSelect()
    end
  end
  self:StopSuggestions()
end
function InlineTextSuggestions:OnTextInputEndEdit()
end
function InlineTextSuggestions:GetIsVisible()
  return UiCanvasBus.Event.GetEnabled(self.canvasId)
end
return InlineTextSuggestions
