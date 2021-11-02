local TextInputSearchListItem = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    }
  },
  pressCallback = nil,
  pressTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TextInputSearchListItem)
function TextInputSearchListItem:OnInit()
  BaseElement.OnInit(self)
end
function TextInputSearchListItem:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function TextInputSearchListItem:SetCategory(category)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, false)
  UiTextBus.Event.SetColor(self.Text, self.UIStyle.COLOR_TAN)
  local categoryText = string.format("@CategoryData_%s", category)
  UiTextBus.Event.SetTextWithFlags(self.Text, categoryText, eUiTextSet_SetLocalized)
  self.ScriptedEntityTweener:Set(self.Text, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Background, {opacity = 0})
end
function TextInputSearchListItem:GetItemNameWithTier(itemData)
  local tierString = GetRomanFromNumber(itemData.tier)
  local text = GetLocalizedReplacementText("@ui_item_name_with_tier", {
    tierString = tierString,
    itemName = itemData.displayName
  })
  return text
end
function TextInputSearchListItem:SetItemData(data, nameWithTier)
  self.itemData = data
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, true)
  UiTextBus.Event.SetColor(self.Text, self.UIStyle.COLOR_WHITE)
  local displayName = data.displayName
  if nameWithTier then
    displayName = self:GetItemNameWithTier(data)
  end
  UiTextBus.Event.SetTextWithFlags(self.Text, displayName, eUiTextSet_SetLocalized)
  self.ScriptedEntityTweener:Set(self.Text, {opacity = 0.5})
  self.ScriptedEntityTweener:Set(self.Background, {opacity = 0})
end
function TextInputSearchListItem:ExecuteCallback(scopeTable, pressCallback)
  if pressCallback ~= nil and scopeTable ~= nil then
    if type(pressCallback) == "function" then
      pressCallback(scopeTable, self.itemData)
    elseif type(scopeTable[pressCallback]) == "function" then
      scopeTable[pressCallback](scopeTable, self.itemData)
    end
  end
end
function TextInputSearchListItem:OnFocus()
  self.ScriptedEntityTweener:Play(self.Background, 0.1, {opacity = 0.5, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Text, 0.1, {opacity = 1, ease = "QuadOut"})
end
function TextInputSearchListItem:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Background, 0.05, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Text, 0.05, {opacity = 0.5, ease = "QuadOut"})
end
function TextInputSearchListItem:OnSelect()
  self:ExecuteCallback(self.pressTable, self.pressCallback)
end
return TextInputSearchListItem
