local ScreenHeader = {
  Properties = {
    ContentHolder = {
      default = EntityId()
    },
    InputBlocker = {
      default = EntityId()
    },
    HeaderHolder = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    BackHint = {
      default = EntityId()
    },
    MainBg = {
      default = EntityId()
    },
    CurrencyHolder = {
      default = EntityId()
    },
    CurrencyDisplay = {
      default = EntityId()
    },
    CurrencyCoinLabel = {
      default = EntityId()
    },
    CurrencyCoinData = {
      default = EntityId()
    },
    CurrencyAzothContainer = {
      default = EntityId()
    },
    CurrencyAzothLabel = {
      default = EntityId()
    },
    CurrencyAzothData = {
      default = EntityId()
    },
    RightSideHolder = {
      default = EntityId()
    },
    SkillHolder = {
      default = EntityId()
    },
    SkillContainer1 = {
      default = EntityId()
    },
    SkillContainer1Icon = {
      default = EntityId()
    },
    SkillContainer1Label = {
      default = EntityId()
    },
    Skill1Circle = {
      default = EntityId()
    },
    Skill1FlashLong = {
      default = EntityId()
    },
    Skill1FlashShort = {
      default = EntityId()
    },
    SkillContainer2 = {
      default = EntityId()
    },
    SkillContainer2Icon = {
      default = EntityId()
    },
    SkillContainer2Label = {
      default = EntityId()
    },
    Skill2Circle = {
      default = EntityId()
    },
    Skill2FlashLong = {
      default = EntityId()
    },
    Skill2FlashShort = {
      default = EntityId()
    },
    SkillContainer3 = {
      default = EntityId()
    },
    SkillContainer3Icon = {
      default = EntityId()
    },
    SkillContainer3Label = {
      default = EntityId()
    },
    Skill3Circle = {
      default = EntityId()
    },
    Skill3FlashLong = {
      default = EntityId()
    },
    Skill3FlashShort = {
      default = EntityId()
    }
  },
  SCREEN_HEADER_STYLE_DEFAULT = 0,
  SCREEN_HEADER_STYLE_COIN = 1,
  SCREEN_HEADER_STYLE_COIN_AND_AZOTH = 2,
  SCREEN_HEADER_STYLE_SKILL = 3,
  SCREEN_HEADER_STYLE_SKILL_AND_CURRENCY = 4,
  headerStyle = 0,
  isSkill2Visible = true,
  isSkill3Visible = true,
  skillContainerAnimationTime = 0.2,
  skillBgScaleUp = 1.1,
  textAreaPadding = 25
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
BaseElement:CreateNewElement(ScreenHeader)
function ScreenHeader:OnInit()
  BaseElement.OnInit(self)
  self:SetVisualElements()
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  if canvasId and canvasId:IsValid() then
    self.canvasId = canvasId
    AdjustElementToCanvasWidth(self.entityId, self.canvasId)
    self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  end
  self.SkillTextWrapBreakpoint = 200
end
function ScreenHeader:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasWidth(self.entityId, self.canvasId)
  end
end
function ScreenHeader:SetVisualElements()
  SetTextStyle(self.Properties.HeaderText, self.UIStyle.FONT_STYLE_HEADER)
  SetTextStyle(self.Properties.CurrencyCoinLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.CurrencyAzothLabel, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.CurrencyCoinData, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
  SetTextStyle(self.Properties.CurrencyAzothData, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
  SetTextStyle(self.Properties.SkillContainer1Label, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.SkillContainer2Label, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.SkillContainer3Label, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyAzothLabel, "@ui_azoth_currency", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyCoinLabel, "@ui_wallet", eUiTextSet_SetLocalized)
  self:SetHintKeybindMapping("toggleMenuComponent")
  self.BackHint:SetTextColor(self.UIStyle.COLOR_WHITE)
  self:SetStyle(self.SCREEN_HEADER_STYLE_DEFAULT)
end
function ScreenHeader:SetStyle(value)
  self.headerStyle = value
  if self.headerStyle == self.SCREEN_HEADER_STYLE_DEFAULT then
    self:SetSkillVisible(false)
    self:SetCurrencyVisible(false)
  elseif self.headerStyle == self.SCREEN_HEADER_STYLE_COIN then
    self:SetSkillVisible(false)
    self:SetCurrencyVisible(true)
    self:SetAzothVisible(false)
  elseif self.headerStyle == self.SCREEN_HEADER_STYLE_COIN_AND_AZOTH then
    self:SetSkillVisible(false)
    self:SetCurrencyVisible(true)
    self:SetAzothVisible(true)
  elseif self.headerStyle == self.SCREEN_HEADER_STYLE_SKILL then
    self:SetSkillVisible(true)
    self:SetCurrencyVisible(false)
  elseif self.headerStyle == self.SCREEN_HEADER_STYLE_SKILL_AND_CURRENCY then
    self:SetSkillVisible(true)
    self:SetCurrencyVisible(true)
    self:SetAzothVisible(true)
    self:SetCurrencyPosition()
  end
  self:StaggerElements()
end
function ScreenHeader:StaggerElements()
  local delay = 0.15
  self:FlashTradeSkill(self.Properties.Skill1FlashLong, self.Properties.Skill1FlashShort, delay)
  delay = delay + 0.1
  if self.isSkill2Visible then
    self:FlashTradeSkill(self.Properties.Skill2FlashLong, self.Properties.Skill2FlashShort, delay)
    delay = delay + 0.1
  end
  if self.isSkill3Visible then
    self:FlashTradeSkill(self.Properties.Skill3FlashLong, self.Properties.Skill3FlashShort, delay)
    delay = delay + 0.1
  end
  if self.isCurrencyVisible then
    self.ScriptedEntityTweener:Play(self.Properties.CurrencyDisplay, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = delay
    })
    delay = delay + 0.2
  end
  if self.isAzothVisible then
    self.ScriptedEntityTweener:Play(self.Properties.CurrencyAzothContainer, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = delay
    })
  end
end
function ScreenHeader:FlashTradeSkill(entityLong, entityShort, delay)
  self.ScriptedEntityTweener:Stop(entityLong)
  self.ScriptedEntityTweener:Stop(entityShort)
  self.ScriptedEntityTweener:Play(entityShort, 0.1, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = delay
  })
  self.ScriptedEntityTweener:Play(entityLong, 0.1, {opacity = 0, scaleY = 0.6}, {
    opacity = 1,
    scaleY = 1,
    ease = "QuadOut",
    delay = delay
  })
  self.ScriptedEntityTweener:Play(entityShort, 1, {
    opacity = 0,
    ease = "QuadOut",
    delay = delay + 0.1
  })
  self.ScriptedEntityTweener:Play(entityLong, 1, {
    opacity = 0,
    ease = "QuadOut",
    delay = delay + 0.1
  })
end
function ScreenHeader:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.HeaderText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, value, eUiTextSet_SetLocalized)
  end
end
function ScreenHeader:GetText()
  return UiTextBus.Event.GetText(self.Properties.HeaderText)
end
function ScreenHeader:SetTextVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.HeaderText, isVisible)
end
function ScreenHeader:SetHintCallback(callback, table)
  self.BackHint:SetCallback(callback, table)
end
function ScreenHeader:SetHintKeybindMapping(value)
  self.BackHint:SetKeybindMapping(value)
end
function ScreenHeader:SetContentVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.ContentHolder, isVisible)
end
function ScreenHeader:SetBgVisible(isVisible, duration)
  if duration then
    if isVisible then
      self.ScriptedEntityTweener:Play(self.Properties.MainBg, duration, {opacity = 1, ease = "QuadOut"})
    else
      self.ScriptedEntityTweener:Play(self.Properties.MainBg, duration, {opacity = 0, ease = "QuadOut"})
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MainBg, isVisible)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, isVisible)
end
function ScreenHeader:SetCurrencyVisible(isVisible)
  self.isCurrencyVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyHolder, isVisible)
  if isVisible then
    self:SetCurrencyPosition()
  end
end
function ScreenHeader:SetCurrencyPosition()
  local skillCircleWidth = 61
  local iconWidth = 75
  local newPosX = 0
  if self.headerStyle == self.SCREEN_HEADER_STYLE_SKILL_AND_CURRENCY then
    local skill1NameWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SkillContainer1Label)
    newPosX = skill1NameWidth + skillCircleWidth + iconWidth
    if self.isSkill2Visible then
      local skill2NameWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SkillContainer2Label)
      newPosX = newPosX + skill2NameWidth + skillCircleWidth + iconWidth
    end
    if self.isSkill3Visible then
      local skill3NameWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.SkillContainer3Label)
      newPosX = newPosX + skill3NameWidth + skillCircleWidth + iconWidth
    end
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.RightSideHolder, newPosX)
end
function ScreenHeader:SetCoin(value)
  self.CurrencyDisplay:SetCurrencyAmount(value)
end
function ScreenHeader:SetAzoth(value)
  UiTextBus.Event.SetText(self.Properties.CurrencyAzothData, GetFormattedNumber(value or 0))
end
function ScreenHeader:SetAzothVisible(isVisible)
  self.isAzothVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyAzothContainer, isVisible)
end
function ScreenHeader:SetSkillVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.SkillHolder, isVisible)
  if isVisible then
    self:SetSkillTextWrap(self.Properties.SkillContainer1Label)
  end
end
function ScreenHeader:SetSkill1(label)
  local activeTradeskill = Math.CreateCrc32(LyShineScriptBindRequestBus.Broadcast.LocalizeText(label))
  local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(activeTradeskill)
  if tradeSkillData then
    UiImageBus.Event.SetSpritePathname(self.Properties.SkillContainer1Icon, tradeSkillData.smallIcon)
  end
  local labelText = GetLocalizedReplacementText("@ui_station_skill_header", {skillName = label, skillLoc = "@cr_skill"})
  UiTextBus.Event.SetTextWithFlags(self.Properties.SkillContainer1Label, labelText, eUiTextSet_SetLocalized)
end
function ScreenHeader:SetSkill2(label)
  local activeTradeskill = Math.CreateCrc32(LyShineScriptBindRequestBus.Broadcast.LocalizeText(label))
  local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(activeTradeskill)
  if tradeSkillData then
    UiImageBus.Event.SetSpritePathname(self.Properties.SkillContainer2Icon, tradeSkillData.smallIcon)
  end
  local labelText = GetLocalizedReplacementText("@ui_station_skill_header", {skillName = label, skillLoc = "@cr_skill"})
  UiTextBus.Event.SetTextWithFlags(self.Properties.SkillContainer2Label, labelText, eUiTextSet_SetLocalized)
end
function ScreenHeader:SetSkill2Visible(isVisible)
  self.isSkill2Visible = isVisible
  UiElementBus.Event.SetIsEnabled(self.Properties.SkillContainer2, isVisible)
  if isVisible then
    self:SetSkillTextWrap(self.Properties.SkillContainer2Label)
  end
  self:SetCurrencyPosition()
end
function ScreenHeader:SetSkill3(label)
  local activeTradeskill = Math.CreateCrc32(LyShineScriptBindRequestBus.Broadcast.LocalizeText(label))
  local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(activeTradeskill)
  if tradeSkillData then
    UiImageBus.Event.SetSpritePathname(self.Properties.SkillContainer3Icon, tradeSkillData.smallIcon)
  end
  local labelText = GetLocalizedReplacementText("@ui_station_skill_header", {skillName = label, skillLoc = "@cr_skill"})
  UiTextBus.Event.SetTextWithFlags(self.Properties.SkillContainer3Label, labelText, eUiTextSet_SetLocalized)
end
function ScreenHeader:SetSkill3Visible(isVisible)
  self.isSkill3Visible = isVisible
  UiElementBus.Event.SetIsEnabled(self.Properties.SkillContainer3, isVisible)
  if isVisible then
    self:SetSkillTextWrap(self.Properties.SkillContainer3Label)
  end
  self:SetCurrencyPosition()
end
function ScreenHeader:SetSkill1Circle(level, progress)
  self.Skill1Circle:SetLevel(level)
  self.Skill1Circle:SetProgress(progress)
end
function ScreenHeader:SetSkill2Circle(level, progress)
  self.Skill2Circle:SetLevel(level)
  self.Skill2Circle:SetProgress(progress)
end
function ScreenHeader:SetSkill3Circle(level, progress)
  self.Skill3Circle:SetLevel(level)
  self.Skill3Circle:SetProgress(progress)
end
function ScreenHeader:SetSkillTextWrap(textElement)
  UiTextBus.Event.SetWrapText(textElement, self.UIStyle.TEXT_WRAP_SETTING_NO_WRAP)
  UiTransform2dBus.Event.SetLocalWidth(textElement, self.SkillTextWrapBreakpoint)
  local getInitialTextWidth = UiTextBus.Event.GetTextWidth(textElement)
  if not self.isSkill2Visible then
    UiTransform2dBus.Event.SetLocalWidth(textElement, getInitialTextWidth)
    return
  end
  if getInitialTextWidth < self.SkillTextWrapBreakpoint then
    local getInitialElementWidth = UiTransform2dBus.Event.GetLocalWidth(textElement)
    if getInitialTextWidth < getInitialElementWidth then
      UiTransform2dBus.Event.SetLocalWidth(textElement, getInitialTextWidth)
    end
    return
  end
  if getInitialTextWidth > self.SkillTextWrapBreakpoint and self.isSkill2Visible then
    UiTextBus.Event.SetWrapText(textElement, self.UIStyle.TEXT_WRAP_SETTING_WRAP)
    local getWrappedTextWidth = UiTextBus.Event.GetTextWidth(textElement)
    UiTransform2dBus.Event.SetLocalWidth(textElement, getWrappedTextWidth)
    local getWrappedTextWidthAgain = UiTextBus.Event.GetTextWidth(textElement)
    UiTransform2dBus.Event.SetLocalWidth(textElement, getWrappedTextWidthAgain)
    local postWrapTextWidth = UiTextBus.Event.GetTextWidth(textElement)
    local postWrapElementWidth = UiTransform2dBus.Event.GetLocalWidth(textElement)
    if getWrappedTextWidthAgain > postWrapTextWidth and postWrapTextWidth < postWrapElementWidth then
      UiTransform2dBus.Event.SetLocalWidth(textElement, postWrapTextWidth + self.textAreaPadding)
    end
  end
end
function ScreenHeader:OnShutdown()
end
return ScreenHeader
