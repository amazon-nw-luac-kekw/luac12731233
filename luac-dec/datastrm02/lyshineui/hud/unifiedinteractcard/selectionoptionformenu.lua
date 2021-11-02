local SelectionOptionForMenu = {
  Properties = {
    AdditionalInfo = {
      default = EntityId()
    },
    ButtonText = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    },
    HoverText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SelectionOptionForMenu)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function SelectionOptionForMenu:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self:BusConnect(UnifiedInteractOptionNotificationsBus, self.entityId)
  UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalInfo, false)
  self.enabledColor = ColorRgba(255, 255, 255, 1)
  self.disabledColor = ColorRgba(128, 128, 128, 1)
  UiTextBus.Event.SetFont(self.ButtonText, self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR)
  UiTextBus.Event.SetFontSize(self.ButtonText, 29)
  UiTextBus.Event.SetFontEffect(self.ButtonText, 1)
  UiTextBus.Event.SetColor(self.ButtonText, self.enabledColor)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, 0)
  self.ScriptedEntityTweener:Set(self.Properties.HoverText, {opacity = 0})
  UiTextBus.Event.SetFont(self.HoverText, self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR)
  UiTextBus.Event.SetFontSize(self.HoverText, 29)
  UiTextBus.Event.SetFontEffect(self.HoverText, 1)
  UiTextBus.Event.SetColor(self.HoverText, self.disabledColor)
  UiTextBus.Event.SetCharacterSpacing(self.HoverText, 0)
end
function SelectionOptionForMenu:OnAction(entityId, action)
  if string.find(action, ":") ~= nil then
    local actionSplitTable = StringSplit(action, ":")
    local actionScope = actionSplitTable[1]
    local actionFunction = actionSplitTable[2]
    if type(self[actionFunction]) == "function" then
      self[actionFunction](self, entityId)
    end
  end
end
function SelectionOptionForMenu:OnFocus(entityId)
  if entityId ~= self.Button.entityId then
    return
  end
  if self.Button.mIsEnabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalInfo, true)
    self.ScriptedEntityTweener:Play(self.Properties.AdditionalInfo, 0.2, {opacity = 0}, {opacity = 1})
  else
    local hoverText = UiTextBus.Event.GetText(self.Properties.HoverText)
    self.Button:SetTooltip(hoverText)
  end
end
function SelectionOptionForMenu:OnUnfocus(entityId)
  if entityId ~= self.Button.entityId then
    return
  end
  if self.Button.mIsEnabled then
    self.ScriptedEntityTweener:Play(self.Properties.AdditionalInfo, 0.2, {opacity = 1}, {
      opacity = 0,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalInfo, false)
      end
    })
  end
end
function SelectionOptionForMenu:OnCanExecuteInteractOptionChanged(canExecute)
  self.Button:SetEnabled(canExecute)
  UiElementBus.Event.SetIsEnabled(self.Properties.HoverText, not canExecute)
  UiTextBus.Event.SetColor(self.ButtonText, canExecute and self.enabledColor or self.disabledColor)
end
return SelectionOptionForMenu
