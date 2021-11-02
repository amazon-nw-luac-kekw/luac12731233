local TutorialKeyBind = {
  Properties = {
    KeyContainer = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    HoldText = {
      default = EntityId()
    },
    MouseButtonContainer = {
      default = EntityId()
    },
    MouseButtons = {
      LMB = {
        default = EntityId()
      },
      RMB = {
        default = EntityId()
      },
      MMB = {
        default = EntityId()
      },
      MB = {
        default = EntityId()
      },
      HoldText = {
        default = EntityId()
      }
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TutorialKeyBind)
function TutorialKeyBind:SetKeyBinding(actionName, actionMap, showHold, hintFontSize, hintMinWidth, highlightVisible)
  if not showHold then
    UiTextBus.Event.SetText(self.Properties.HoldText, "")
  end
  self.Hint:SetFontSize(hintFontSize or 30)
  self.Hint:SetMinWidth(hintMinWidth or 40)
  self.Hint:SetActionMap(actionMap)
  self.Hint:SetKeybindMapping(actionName)
  self.Hint:SetHighlightVisible(highlightVisible)
  local holdW = 0
  if showHold then
    holdW = UiTextBus.Event.GetTextWidth(self.Properties.HoldText) + 10
  end
  local newWidth = self.Hint:GetWidth() + holdW
  self:SetWidth(newWidth)
  self:HideMouseButtons()
  UiFaderBus.Event.SetFadeValue(self.Properties.KeyContainer, 1)
end
function TutorialKeyBind:SetMouseBinding(mouseButtonId, showHold)
  UiElementBus.Event.SetIsEnabled(self.Properties.MouseButtons.HoldText, showHold)
  self:HideMouseButtons()
  UiFaderBus.Event.SetFadeValue(self.Properties.KeyContainer, 0)
  local button = self.Properties.MouseButtons.MB
  if mouseButtonId == "mouse1" then
    button = self.Properties.MouseButtons.LMB
  elseif mouseButtonId == "mouse2" then
    button = self.Properties.MouseButtons.RMB
  elseif mouseButtonId == "mouse3" or mouseButtonId == "mwheel_up" or mouseButtonId == "mwheel_down" then
    button = self.Properties.MouseButtons.MMB
  end
  UiFaderBus.Event.SetFadeValue(button, 1)
  local holdW = 0
  if showHold then
    holdW = UiTextBus.Event.GetTextWidth(self.Properties.MouseButtons.HoldText)
  end
  local newWidth = UiTransform2dBus.Event.GetLocalWidth(button) + holdW
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.MouseButtonContainer, newWidth)
  self:SetWidth(newWidth)
end
function TutorialKeyBind:HideMouseButtons()
  for i, button in ipairs(self.Properties.MouseButtons) do
    UiFaderBus.Event.SetFadeValue(button, 0)
  end
end
function TutorialKeyBind:SetWidth(newWidth)
  UiLayoutCellBus.Event.SetMinWidth(self.entityId, newWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.KeyContainer, newWidth)
end
return TutorialKeyBind
