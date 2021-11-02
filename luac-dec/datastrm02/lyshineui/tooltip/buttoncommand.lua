local ButtonCommand = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    SecondaryText = {
      default = EntityId()
    },
    SecondaryTextHint = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonHintHolder = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    TertiaryText = {
      default = EntityId()
    },
    Cross = {
      default = EntityId()
    },
    SecondaryTextIcon = {
      default = EntityId()
    },
    WithText = {
      default = EntityId()
    },
    TooltipDelay = {default = 0.3}
  },
  width = nil,
  height = nil,
  callback = nil,
  callbackTable = nil,
  buttonHint = nil,
  initBgAlpha = 0.5,
  mSoundOnFocus = nil,
  mSoundOnPress = nil,
  mWidth = 100,
  mHeight = 30,
  mIndex = nil,
  mEnabled = true,
  mIsSelected = false,
  mPressCallback = nil,
  mPressTable = nil,
  mFocusCallback = nil,
  mFocusTable = nil,
  mUnfocusCallback = nil,
  mUnfocusTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ButtonCommand)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(ButtonCommand)
function ButtonCommand:OnInit()
  BaseElement.OnInit(self)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.textHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ButtonText)
  self.textWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ButtonText)
  self.secondaryTextPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.SecondaryText)
  self.secondaryTextPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.SecondaryText)
  self.tertiaryTextPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.TertiaryText)
  self:SetSize(self.width, self.height)
  self.mSoundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.mSoundOnPress = self.audioHelper.Accept
  self.originalBgColor = UiImageBus.Event.GetColor(self.Properties.ButtonBg)
  if self.Properties.SecondaryTextHint:IsValid() and type(self.SecondaryTextHint) == "table" then
    self.SecondaryTextHint:SetFontSize(28)
  end
end
function ButtonCommand:SetCallback(command, table)
  self.mPressCallback = command
  self.mPressTable = table
end
function ButtonCommand:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function ButtonCommand:SetHeight(height)
  self.height = height
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function ButtonCommand:GetWidth()
  return self.width
end
function ButtonCommand:GetHeight()
  return self.height
end
function ButtonCommand:SetEnabled(enabled)
  self.mEnabled = enabled
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryText, enabled)
end
function ButtonCommand:GetEnabled()
  return self.mEnabled
end
function ButtonCommand:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
end
function ButtonCommand:SetSecondaryText(value)
  UiTextBus.Event.SetTextWithFlags(self.SecondaryText, value, eUiTextSet_SetLocalized)
end
function ButtonCommand:SetSecondaryTextStyle(style)
  SetTextStyle(self.Properties.SecondaryText, style)
end
function ButtonCommand:SetSecondaryTextIcon(path)
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextIcon, path and true or false)
  if path then
    UiImageBus.Event.SetSpritePathname(self.Properties.SecondaryTextIcon, path)
    local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SecondaryTextIcon)
    local spacing = 2
    UiTransformBus.Event.SetLocalPositionX(self.Properties.SecondaryText, self.secondaryTextPosX - iconWidth - spacing)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.SecondaryText, self.secondaryTextPosX)
  end
end
function ButtonCommand:SetCrossVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Cross, isVisible)
end
function ButtonCommand:SetSecondaryTextHint(keybinding)
  if self.Properties.SecondaryTextHint:IsValid() and type(self.SecondaryTextHint) == "table" then
    if keybinding then
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextHint, true)
      self.SecondaryTextHint:SetText(keybinding)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryTextHint, false)
    end
  end
end
function ButtonCommand:SetTertiaryText(value)
  if self.Properties.TertiaryText:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TertiaryText, value, eUiTextSet_SetLocalized)
  end
end
function ButtonCommand:SetTertiaryTextStyle(style)
  SetTextStyle(self.Properties.TertiaryText, style)
end
function ButtonCommand:SetTextHeight(height)
  if height then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonText, height)
  else
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonText, self.textHeight)
  end
end
function ButtonCommand:SetTertiaryTextPositionY(yPos)
  if yPos then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TertiaryText, yPos)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TertiaryText, self.tertiaryTextPosY)
  end
end
function ButtonCommand:SetSecondaryTextPosY(yPos)
  if yPos then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.SecondaryText, yPos)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.SecondaryText, self.secondaryTextPosY)
  end
end
function ButtonCommand:SetDividerVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Divider, isVisible)
end
function ButtonCommand:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function ButtonCommand:SetTextWidth(width)
  if width then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {w = width})
  else
    self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {
      w = self.textWidth
    })
  end
end
function ButtonCommand:SetWithText(text)
  if not self.Properties.WithText:IsValid() then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.WithText, text and text ~= "")
  if text and text ~= "" then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WithText, text, eUiTextSet_SetLocalized)
  end
end
function ButtonCommand:SetTextColor(color)
  self.ScriptedEntityTweener:Set(self.ButtonText, {textColor = color})
end
function ButtonCommand:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.ButtonText, value)
end
function ButtonCommand:GetFontSize(value)
  return UiTextBus.Event.GetFontSize(self.ButtonText)
end
function ButtonCommand:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, value)
end
function ButtonCommand:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.ButtonText)
end
function ButtonCommand:SetTextStyle(value)
  SetTextStyle(self.ButtonText, value)
end
function ButtonCommand:SetIsDivider(isDivider)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonBg, not isDivider)
end
function ButtonCommand:SetBGColor(color)
  if color then
    UiImageBus.Event.SetColor(self.Properties.ButtonBg, color)
  else
    UiImageBus.Event.SetColor(self.Properties.ButtonBg, self.originalBgColor)
  end
end
function ButtonCommand:SetTooltipInfo(tooltipInfo)
  self.tooltipInfo = tooltipInfo
end
function ButtonCommand:OnTick(deltaTime, timePoint)
  self.timeToWait = self.timeToWait - deltaTime
  if self.timeToWait <= 0 then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
    local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
    if not isStillEnabled or not canvasEnabled then
      return
    end
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.tooltipInfo, self, nil)
  end
end
function ButtonCommand:OnFocus()
  if type(self.tooltipInfo) == "table" then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    self.timeToWait = self.Properties.TooltipDelay
  end
  self.audioHelper:PlaySound(self.mSoundOnFocus)
  if not self.mEnabled then
    return
  end
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = self.initBgAlpha
    })
    self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  if self.buttonHint ~= nil then
    self.buttonHint:OnFocus()
  end
end
function ButtonCommand:OnUnfocus()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if not self.mEnabled then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
    opacity = self.initBgAlpha,
    ease = "QuadOut"
  })
  if self.buttonHint ~= nil then
    self.buttonHint:OnUnfocus()
  end
end
function ButtonCommand:OnPress()
  if not self.mEnabled then
    return
  end
  self.ScriptedEntityTweener:Play(self.ButtonBg, 0.05, {opacity = 0.6, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
    scaleX = 0.95,
    scaleY = 0.95,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {
    scaleX = 1,
    scaleY = 1,
    delay = 0.05
  })
  self.audioHelper:PlaySound(self.mSoundOnPress)
  self:ExecuteCallback(self.mPressTable, self.mPressCallback)
end
function ButtonCommand:ExecuteCallback(scopeTable, pressCallback)
  if pressCallback ~= nil and scopeTable ~= nil then
    if type(pressCallback) == "function" then
      pressCallback(scopeTable, self)
    elseif type(scopeTable[pressCallback]) == "function" then
      scopeTable[pressCallback](scopeTable, self)
    end
  end
end
function ButtonCommand:SetHint(hintText, isKeybindName)
  local data = {text = hintText, isKeybind = isKeybindName}
  if self.buttonHint ~= nil then
    self:SetHintData(data)
  else
    self:BusConnect(UiSpawnerNotificationBus, self.ButtonHintHolder)
    self:SpawnSlice(self.ButtonHintHolder, "LyShineUI\\Slices\\Hint", self.OnHintSpawned, data)
  end
end
function ButtonCommand:SetHintData(data)
  if data.isKeybind then
    self.buttonHint:SetKeybindMapping(data.text)
  else
    self.buttonHint:SetText(data.text)
  end
end
function ButtonCommand:OnHintSpawned(entity, data)
  self.buttonHint = entity
  self:SetHintData(data)
  UiInteractableBus.Event.SetIsHandlingEvents(self.buttonHint.entityId, false)
  local textWidth = UiTextBus.Event.GetTextSize(self.ButtonText).x
  local textWidthDifference = self.width - textWidth
  local hintWidth = 44
  local textPosX = hintWidth / 2
  self.ScriptedEntityTweener:Set(self.ButtonText, {x = textPosX})
end
function ButtonCommand:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
function ButtonCommand:SetSoundOnFocus(value)
  self.mSoundOnFocus = value
end
function ButtonCommand:SetSoundOnPress(value)
  self.mSoundOnPress = value
end
function ButtonCommand:SetButtonToListStyle(path)
  UiImageBus.Event.SetSpritePathname(self.ButtonBg, path)
end
return ButtonCommand
