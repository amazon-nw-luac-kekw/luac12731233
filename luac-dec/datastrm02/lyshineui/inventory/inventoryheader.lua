local InventoryHeader = {
  Properties = {
    HeaderTitle = {
      default = EntityId()
    },
    HeaderWeight = {
      default = EntityId()
    },
    HeaderWeightIcon = {
      default = EntityId()
    },
    HeaderLine = {
      default = EntityId()
    }
  },
  mWidth = nil,
  mHeight = nil,
  mIsDimmed = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(InventoryHeader)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function InventoryHeader:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.HeaderWeight, self.UIStyle.FONT_STYLE_INVENTORY_SECTION_WEIGHT)
  SetTextStyle(self.HeaderTitle, self.UIStyle.FONT_STYLE_INVENTORY_SECONDARY_TITLE)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    if self.value then
      self:SetTextWeight(self.value)
    end
  end)
end
function InventoryHeader:GetWidth()
  return self.mWidth
end
function InventoryHeader:GetHeight()
  return self.mHeight
end
function InventoryHeader:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.HeaderTitle, value, eUiTextSet_SetLocalized)
end
function InventoryHeader:GetText()
  return UiTextBus.Event.GetText(self.HeaderTitle)
end
function InventoryHeader:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.HeaderTitle, 2, {textColor = color})
end
function InventoryHeader:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.HeaderTitle, value)
end
function InventoryHeader:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.HeaderTitle, value)
end
function InventoryHeader:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.HeaderTitle, value)
end
function InventoryHeader:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.HeaderTitle)
end
function InventoryHeader:SetTextStyle(value)
  SetTextStyle(self.HeaderTitle, value)
end
function InventoryHeader:SetTextWeight(value)
  self.value = value
  UiTextBus.Event.SetText(self.HeaderWeight, GetFormattedNumber(value, 1, false))
  if value <= 0 and self.mIsDimmed ~= true then
    self:SetHeaderDimmed(true)
  elseif 0 < value and self.mIsDimmed ~= false then
    self:SetHeaderDimmed(false)
  end
end
function InventoryHeader:GetTextWeight()
  return UiTextBus.Event.GetText(self.HeaderWeight)
end
function InventoryHeader:SetTextWeightColor(color)
  self.ScriptedEntityTweener:Play(self.HeaderWeight, 2, {textColor = color})
end
function InventoryHeader:SetLineVisible(isVisible, duration, params)
  local defaultDelay = 0
  local animDelay = defaultDelay
  if params ~= nil then
    animDelay = params.delay ~= nil and params.delay or defaultDelay
  end
  self.HeaderLine:SetVisible(isVisible, duration, {delay = animDelay})
end
function InventoryHeader:SetLineColor(color, duration, params)
  self.HeaderLine:SetColor(color, duration, params)
end
function InventoryHeader:SetLineAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.HeaderLine.entityId, {opacity = alpha})
end
function InventoryHeader:SetHeaderDimmed(isDimmed)
  local duration = 0.2
  if isDimmed == true then
    self.mIsDimmed = true
    self.ScriptedEntityTweener:Play(self.entityId, duration, {opacity = 0.6})
    self.ScriptedEntityTweener:Play(self.HeaderWeight, duration, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.HeaderWeightIcon, duration, {opacity = 0})
  elseif isDimmed == false then
    self.mIsDimmed = false
    self.ScriptedEntityTweener:Play(self.entityId, duration, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.HeaderWeight, duration, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.HeaderWeightIcon, duration, {opacity = 1})
  end
end
function InventoryHeader:SetIconVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.HeaderWeight, isVisible)
  UiElementBus.Event.SetIsEnabled(self.HeaderWeightIcon, isVisible)
end
return InventoryHeader
