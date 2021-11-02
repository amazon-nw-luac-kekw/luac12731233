local ContractBrowser_PerkSelectionListItem = {
  Properties = {
    AnyPerkContainer = {
      default = EntityId()
    },
    PerkInfoContainer = {
      default = EntityId()
    },
    PerkIcon = {
      default = EntityId()
    },
    PerkNameText = {
      default = EntityId()
    },
    AnyPerkLabelText = {
      default = EntityId()
    },
    AnyPerkDescriptionText = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  highlightMaxOpacity = 0.75,
  disabledOpacity = 0.5,
  mIsUsingTooltip = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_PerkSelectionListItem)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function ContractBrowser_PerkSelectionListItem:OnInit()
  BaseElement.OnInit(self)
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = 0})
end
function ContractBrowser_PerkSelectionListItem:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function ContractBrowser_PerkSelectionListItem:GetElementWidth()
  return 350
end
function ContractBrowser_PerkSelectionListItem:GetElementHeight()
  return 72
end
function ContractBrowser_PerkSelectionListItem:GetHorizontalSpacing()
  return 6
end
function ContractBrowser_PerkSelectionListItem:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function ContractBrowser_PerkSelectionListItem:SetGridItemData(data)
  UiElementBus.Event.SetIsEnabled(self.entityId, data ~= nil)
  if not data then
    return
  end
  self.perkId = data.perkId
  self.isDisabled = data.isDisabled
  self.isSelected = data.isSelected
  self.callbackSelf = data.callbackSelf
  self.callbackFunction = data.callbackFunction
  local isAnyPerk = data.perkId == 0
  UiElementBus.Event.SetIsEnabled(self.Properties.AnyPerkContainer, isAnyPerk)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkInfoContainer, not isAnyPerk)
  if isAnyPerk then
    local labelText = data.isSelectingGem and "@ui_perk_selector_any_gem" or "@ui_perk_selector_any_perk"
    local descriptionText = data.isSelectingGem and "@ui_perk_selector_any_gem_description" or "@ui_perk_selector_any_perk_description"
    UiTextBus.Event.SetTextWithFlags(self.Properties.AnyPerkLabelText, labelText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AnyPerkDescriptionText, descriptionText, eUiTextSet_SetLocalized)
  else
    local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(data.perkId)
    local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".png"
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkIconPath)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkNameText, perkData.displayName, eUiTextSet_SetLocalized)
    if self.Properties.ButtonTooltipSetter:IsValid() then
      self:SetTooltip(perkData:GetGenericLocalizedDescription())
    end
  end
  local entityOpacity = self.isDisabled and self.disabledOpacity or 1
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = entityOpacity})
  local invalidSelection = self.isSelected and self.isDisabled
  local opacity = self.isSelected and self.highlightMaxOpacity or 0
  local color = self.isSelected and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_TAN
  if invalidSelection then
    color = self.UIStyle.COLOR_RED
  end
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = opacity, imgColor = color})
  self.ScriptedEntityTweener:Set(self.Properties.Frame, {imgColor = color})
  if self.perkId ~= 0 then
    self.ScriptedEntityTweener:Set(self.Properties.PerkNameText, {textColor = color})
  else
    self.ScriptedEntityTweener:Set(self.Properties.AnyPerkLabelText, {textColor = color})
  end
end
function ContractBrowser_PerkSelectionListItem:OnFocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if self.isDisabled or self.isSelected then
    return
  end
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {
      opacity = self.highlightMaxOpacity
    })
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = self.highlightMaxOpacity,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {
    opacity = self.highlightMaxOpacity,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = self.highlightMaxOpacity,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.imgToWhite)
  if self.perkId ~= 0 then
    self.ScriptedEntityTweener:PlayC(self.Properties.PerkNameText, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.textToWhite)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AnyPerkLabelText, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.textToWhite)
  end
end
function ContractBrowser_PerkSelectionListItem:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if self.isDisabled or self.isSelected then
    return
  end
  if self.highlightTimeline then
    self.highlightTimeline:Stop()
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.3, tweenerCommon.fadeOutQuadIn)
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.3, tweenerCommon.imgToTan)
  if self.perkId ~= 0 then
    self.ScriptedEntityTweener:PlayC(self.Properties.PerkNameText, 0.3, tweenerCommon.textToTan)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.AnyPerkLabelText, 0.3, tweenerCommon.textToTan)
  end
end
function ContractBrowser_PerkSelectionListItem:OnPress()
  if self.isDisabled and not self.isSelected then
    return
  end
  if self.callbackFunction then
    self.callbackFunction(self.callbackSelf, self)
  end
end
return ContractBrowser_PerkSelectionListItem
