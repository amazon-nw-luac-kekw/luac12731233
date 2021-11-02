local CACAppearanceListItem = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFocusArrow = {
      default = EntityId()
    },
    ListWindow = {
      default = EntityId()
    }
  },
  focusColor = nil,
  unfocusColor = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACAppearanceListItem)
function CACAppearanceListItem:OnInit()
  BaseElement.OnInit(self)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_TAN
  local buttonTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 26,
    fontColor = self.unfocusColor,
    characterSpacing = 100
  }
  SetTextStyle(self.ButtonText, buttonTextStyle)
end
function CACAppearanceListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
end
function CACAppearanceListItem:GetText(value)
  return UiTextBus.Event.GetText(self.ButtonText)
end
function CACAppearanceListItem:OnFocus()
  local animDuration = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocusArrow, animDuration, {
    opacity = 1,
    x = 15,
    ease = "QuadOut"
  })
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnAppearenceHover)
end
function CACAppearanceListItem:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState == true then
    self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8})
  else
    self:OnUnselected()
  end
end
function CACAppearanceListItem:OnSelected()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocusArrow, animDuration, {
    opacity = 1,
    x = 15,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {opacity = 0.8, ease = "QuadIn"})
  UiElementBus.Event.SetIsEnabled(self.ListWindow, true)
  self.ScriptedEntityTweener:Play(self.ListWindow, animDuration, {x = 330}, {x = 360, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ListWindow, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnAppearencePress)
end
function CACAppearanceListItem:OnUnselected()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration, {
    textColor = self.unfocusColor,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocusArrow, 0.1, {
    opacity = 0,
    x = 0,
    ease = "QuadIn"
  })
  UiElementBus.Event.SetIsEnabled(self.ListWindow, false)
end
function CACAppearanceListItem:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return CACAppearanceListItem
