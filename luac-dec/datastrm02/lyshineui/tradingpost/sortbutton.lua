local SortButton = {
  Properties = {
    text = {default = "Sort", order = 0},
    displayType = {
      default = eUiHAlign_Center,
      min = eUiHAlign_Left,
      max = eUiHAlign_Right,
      step = 1,
      description = "How to display the SortButton. " .. eUiHAlign_Left .. " for left edge, " .. eUiHAlign_Center .. " for middle segment, " .. eUiHAlign_Right .. " for right edge.",
      order = 1
    },
    usingAchoredText = {
      default = false,
      description = "Set to true if the text is anchored on multiple sides",
      order = 2
    },
    usingNarrowText = {default = false, order = 3},
    SortButtonDivider = {
      default = EntityId()
    },
    SortButtonText = {
      default = EntityId()
    },
    SortButtonHighlight = {
      default = EntityId()
    },
    SortButtonBg = {
      default = EntityId()
    },
    SortButtonBgMasker = {
      default = EntityId()
    },
    SortButtonIcon = {
      default = EntityId()
    }
  },
  textAlignment = eUiHAlign_Left,
  soundOnPress = nil,
  BG_BY_DISPLAY_TYPE = {
    [eUiHAlign_Left] = {
      left = -12,
      pivotX = 0,
      image = "lyshineui/images/tradingpost/sortbuttonbgleft.png"
    },
    [eUiHAlign_Center] = {
      image = "lyshineui/images/tradingpost/sortbuttonbgmid.png"
    },
    [eUiHAlign_Right] = {
      right = 12,
      pivotX = 1,
      image = "lyshineui/images/tradingpost/sortbuttonbgright.png"
    }
  },
  ACTIVE_BG_OPACITY = 0.3,
  FOCUSED_BG_OPACITY = 0.2,
  ICON_POSITION_X = {selected = 14.5, deselected = 4.5},
  TEXT_POSITION_X = {selected = 25, deselected = 10},
  ICON_POSITION_NARROW_X = {selected = 6.5, deselected = -7.5},
  TEXT_POSITION_NARROW_X = {selected = 7, deselected = 0},
  ANCHORED_TEXT_POSITION_X = {selected = 18, deselected = 0},
  ASCENDING = 0,
  DESCENDING = 1,
  isSelected = false,
  isFocused = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SortButton)
function SortButton:OnInit()
  BaseElement.OnInit(self)
  if self.Properties.usingNarrowText then
    SetTextStyle(self.SortButtonText, self.UIStyle.FONT_STYLE_SORT_BUTTON_NORMAL)
  else
    SetTextStyle(self.SortButtonText, self.UIStyle.FONT_STYLE_SORT_BUTTON_UPPER)
  end
  self:SetDisplayType(self.Properties.displayType)
  self:SetText(self.Properties.text)
  local elementWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local selectedX = self.Properties.usingNarrowText and self.TEXT_POSITION_NARROW_X.selected or self.TEXT_POSITION_X.selected
  local deselectedX = self.Properties.usingNarrowText and self.TEXT_POSITION_NARROW_X.deselected or self.TEXT_POSITION_X.deselected
  if elementWidth ~= 0 then
    UiTransform2dBus.Event.SetLocalWidth(self.SortButtonText, elementWidth - selectedX - deselectedX / 2)
  end
  self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.highlightTimeline:Add(self.SortButtonHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.05})
  self.highlightTimeline:Add(self.SortButtonHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.2})
  self.highlightTimeline:Add(self.SortButtonHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
    opacity = 0.2,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  self.soundOnPress = self.audioHelper.Accept
  self:UpdateAppearance()
end
function SortButton:OnShutdown()
  self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
end
function SortButton:SetDisplayType(type)
  if self.SortButtonBg ~= nil then
    local targetOffsets = UiOffsets(self.BG_BY_DISPLAY_TYPE[type].left or 0, 0, self.BG_BY_DISPLAY_TYPE[type].right or -1, 0)
    UiTransform2dBus.Event.SetOffsets(self.SortButtonBgMasker, targetOffsets)
    UiTransformBus.Event.SetPivotX(self.SortButtonBg, self.BG_BY_DISPLAY_TYPE[type].pivotX or 0.5)
    UiTransformBus.Event.SetPivotX(self.SortButtonHighlight, self.BG_BY_DISPLAY_TYPE[type].pivotX or 0.5)
    UiImageBus.Event.SetSpritePathname(self.SortButtonBg, self.BG_BY_DISPLAY_TYPE[type].image or self.BG_BY_DISPLAY_TYPE[eUiHAlign_Center].image)
    if type ~= eUiHAlign_Right then
      UiElementBus.Event.SetIsEnabled(self.SortButtonDivider, true)
    else
      UiElementBus.Event.SetIsEnabled(self.SortButtonDivider, false)
    end
  end
end
function SortButton:OnFocus()
  self.isFocused = true
  self:UpdateAppearance()
end
function SortButton:OnUnfocus()
  self.isFocused = false
  self:UpdateAppearance()
end
function SortButton:OnPress()
  self.audioHelper:PlaySound(self.soundOnPress)
  if self.pressTable and self.pressCallback then
    self:ExecuteCallback(self.pressTable, self.pressCallback)
  end
end
function SortButton:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function SortButton:ExecuteCallback(scopeTable, pressCallback)
  if pressCallback ~= nil and scopeTable ~= nil then
    if type(pressCallback) == "function" then
      pressCallback(scopeTable, self)
    elseif type(scopeTable[pressCallback]) == "function" then
      scopeTable[pressCallback](scopeTable, self)
    end
  end
end
function SortButton:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.SortButtonText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.SortButtonText, value, eUiTextSet_SetLocalized)
  end
end
function SortButton:UpdateAppearance(duration)
  duration = duration or 0.15
  local color = self.UIStyle.COLOR_SORT_BUTTON_DESELECTED
  local bgOpacity = 0
  local bgColor = self.UIStyle.COLOR_TAN
  local textX = self.Properties.usingAchoredText and self.ANCHORED_TEXT_POSITION_X.deselected or self.TEXT_POSITION_X.deselected
  if self.Properties.usingNarrowText then
    textX = self.TEXT_POSITION_NARROW_X.deselected
  end
  local iconX = self.ICON_POSITION_X.deselected
  if self.Properties.usingNarrowText then
    iconX = self.ICON_POSITION_NARROW_X.deselected
  end
  local iconRotation = 0
  local iconOpacity = 0
  if self.isSelected then
    color = self.UIStyle.COLOR_SORT_BUTTON_SELECTED
    bgOpacity = self.ACTIVE_BG_OPACITY
    textX = self.Properties.usingAchoredText and self.ANCHORED_TEXT_POSITION_X.selected or self.TEXT_POSITION_X.selected
    if self.Properties.usingNarrowText then
      textX = self.TEXT_POSITION_NARROW_X.selected
    end
    iconX = self.ICON_POSITION_X.selected
    if self.Properties.usingNarrowText then
      iconX = self.ICON_POSITION_NARROW_X.selected
    end
    iconOpacity = 1
    if self.direction == self.DESCENDING then
      iconRotation = 180
    end
  end
  if self.isFocused then
    color = self.UIStyle.COLOR_SORT_BUTTON_HIGHLIGHTED
    bgOpacity = self.FOCUSED_BG_OPACITY
    bgColor = self.UIStyle.COLOR_WHITE
    self.ScriptedEntityTweener:Play(self.Properties.SortButtonHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.2, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SortButtonHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 0.2,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  else
    self.highlightTimeline:Stop()
    self.ScriptedEntityTweener:Play(self.SortButtonHighlight, duration, {opacity = 0})
  end
  local anchors = UiTransform2dBus.Event.GetAnchors(self.SortButtonText)
  self.ScriptedEntityTweener:Play(self.SortButtonText, duration, {textColor = color, x = textX})
  self.ScriptedEntityTweener:Play(self.SortButtonBg, duration, {imgColor = bgColor, opacity = bgOpacity})
  self.ScriptedEntityTweener:Play(self.SortButtonIcon, duration, {
    imgColor = color,
    x = iconX,
    rotation = iconRotation,
    opacity = iconOpacity
  })
end
function SortButton:SetSelectedDescending()
  self.isSelected = true
  self.direction = self.DESCENDING
  self:UpdateAppearance()
end
function SortButton:SetSelectedAscending()
  self.isSelected = true
  self.direction = self.ASCENDING
  self:UpdateAppearance()
end
function SortButton:SetDeselected()
  self.isSelected = false
  self:UpdateAppearance()
end
function SortButton:SetIsHandlingEvents(isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, isHandlingEvents)
end
return SortButton
