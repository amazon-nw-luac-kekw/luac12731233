local MapMenuButton = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonTextSmall = {
      default = EntityId()
    },
    ButtonSubText = {
      default = EntityId()
    },
    ButtonHeaderText = {
      default = EntityId()
    },
    ButtonHeaderTextSmall = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFocusGlow = {
      default = EntityId()
    },
    ButtonGuildCrest = {
      default = EntityId()
    },
    ButtonIcon = {
      default = EntityId()
    },
    ButtonIconHolder = {
      default = EntityId()
    },
    IsFilterButton = {default = false},
    CounterText = {
      default = EntityId()
    },
    CounterBg = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    }
  },
  subTextOffsetY = -6
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapMenuButton)
function MapMenuButton:OnInit()
  BaseElement.OnInit(self)
  local style = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 20,
    fontColor = self.UIStyle.COLOR_TAN
  }
  if self.IsFilterButton then
    style.fontSize = 17
  end
  SetTextStyle(self.ButtonText, style)
  style.fontSize = 19
  style.fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM
  SetTextStyle(self.ButtonSubText, style)
  self.ScriptedEntityTweener:Set(self.ButtonFocus, {opacity = 0.5})
end
function MapMenuButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function MapMenuButton:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function MapMenuButton:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.ButtonText, value)
    UiTextBus.Event.SetText(self.ButtonTextSmall, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.ButtonTextSmall, value, eUiTextSet_SetLocalized)
  end
end
function MapMenuButton:SetCounterText(value)
  UiTextBus.Event.SetText(self.Properties.CounterText, value)
end
function MapMenuButton:ShowCounter(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.CounterBg, isVisible)
end
function MapMenuButton:SetHeaderText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.ButtonHeaderText, value)
    UiTextBus.Event.SetText(self.ButtonHeaderTextSmall, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.ButtonHeaderText, value, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.ButtonHeaderTextSmall, value, eUiTextSet_SetLocalized)
  end
end
function MapMenuButton:SetSubText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.ButtonSubText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.ButtonSubText, value, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.ButtonSubText, 0 < #value)
  UiTransformBus.Event.SetLocalPositionY(self.ButtonText, self.subTextOffsetY)
end
function MapMenuButton:SetIcon(path, color)
  self.ButtonIcon:SetIcon(path, color)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIcon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonGuildCrest, false)
end
function MapMenuButton:SetCrest(crestData)
  self.ButtonGuildCrest:SetIcon(crestData)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonGuildCrest, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIcon, false)
end
function MapMenuButton:OnFocus()
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.ButtonHeaderText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Hover, animDuration1, {opacity = 1, ease = "QuadOut"})
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function MapMenuButton:OnUnfocus()
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_OUT
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_TAN
  })
  self.ScriptedEntityTweener:Play(self.ButtonHeaderText, animDuration1, {
    textColor = self.UIStyle.COLOR_TAN
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 0.5, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.Hover, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
end
function MapMenuButton:OnPress()
  local animDuration1 = 0.1
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 0.5, ease = "QuadIn"})
  self:ExecuteCallback(self.pressTable, self.pressCallback)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function MapMenuButton:ExecuteCallback(scopeTable, callback)
  if scopeTable and callback then
    callback(scopeTable, self)
  end
end
function MapMenuButton:AnimateButtonToSmall(isSmall)
  local animDuration1 = 0.3
  if isSmall then
    self.ScriptedEntityTweener:Play(self.entityId, animDuration1, {w = 300}, {w = 102, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonGuildCrest, animDuration1, {
      x = 61,
      y = 0,
      scaleX = 1,
      scaleY = 1
    }, {
      x = 51,
      y = -18,
      scaleX = 0.73,
      scaleY = 0.73,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.ButtonIconHolder, animDuration1, {
      x = 61,
      y = 0,
      scaleX = 1,
      scaleY = 1
    }, {
      x = 51,
      y = -14,
      scaleX = 0.8,
      scaleY = 0.8,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.ButtonText, false)
    UiElementBus.Event.SetIsEnabled(self.ButtonHeaderText, false)
    self.ScriptedEntityTweener:Set(self.ButtonSubText, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.ButtonHeaderTextSmall, animDuration1, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.ButtonTextSmall, animDuration1, {opacity = 1})
  else
    self.ScriptedEntityTweener:Play(self.entityId, animDuration1, {w = 102}, {w = 300, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonGuildCrest, animDuration1, {
      x = 51,
      y = -18,
      scaleX = 0.73,
      scaleY = 0.73
    }, {
      x = 61,
      y = 0,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.ButtonIconHolder, animDuration1, {
      x = 51,
      y = -14,
      scaleX = 0.8,
      scaleY = 0.8
    }, {
      x = 61,
      y = 0,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.ButtonText, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHeaderText, true)
    self.ScriptedEntityTweener:Set(self.ButtonSubText, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.ButtonHeaderTextSmall, animDuration1, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.ButtonTextSmall, animDuration1, {opacity = 0})
  end
end
return MapMenuButton
