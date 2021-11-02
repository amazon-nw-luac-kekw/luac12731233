local ContractBrowser_PerkSelector = {
  Properties = {
    PerkIcon = {
      default = EntityId()
    },
    SelectButton = {
      default = EntityId()
    },
    RemoveButton = {
      default = EntityId()
    },
    SelectedPerkText = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  isGemSelector = false,
  exclusiveLabels = nil,
  mIsUsingTooltip = false,
  SELECT_BUTTON_ID = -1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_PerkSelector)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function ContractBrowser_PerkSelector:OnInit()
  BaseElement.OnInit(self)
  self.SelectButton:SetCallback(self.OnSelect, self)
  SetTextStyle(self.Properties.SelectedPerkText, self.UIStyle.FONT_STYLE_BODY_NEW)
end
function ContractBrowser_PerkSelector:SetPerkSelectorData(perkId)
  self.perkId = perkId
  UiElementBus.Event.SetIsEnabled(self.entityId, perkId ~= nil)
  if not perkId then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkIcon, self.perkId ~= self.SELECT_BUTTON_ID)
  UiElementBus.Event.SetIsEnabled(self.Properties.RemoveButton, self.perkId ~= self.SELECT_BUTTON_ID)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectButton, self.perkId == self.SELECT_BUTTON_ID)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedPerkText, self.perkId ~= self.SELECT_BUTTON_ID)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.SelectButton, self.perkId ~= self.SELECT_BUTTON_ID and 35 or 0)
  if perkId ~= self.SELECT_BUTTON_ID then
    if perkId == 0 then
      local anyText = self.isGemSelector and "@ui_buyorder_any_gem" or "@ui_buyorder_any_perk"
      UiTextBus.Event.SetTextWithFlags(self.Properties.SelectedPerkText, anyText, eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, contractsDataHandler.anyPerkIconPath)
    else
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SelectedPerkText, perkData.displayName, eUiTextSet_SetLocalized)
      if self.Properties.ButtonTooltipSetter:IsValid() then
        local localizedDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(perkData.description)
        self:SetTooltip(localizedDescription)
      end
      local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
      UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkIconPath)
      self.exclusiveLabels = perkData.exclusiveLabels
    end
  else
    local buttonText = self.isGemSelector and "@ui_buyorder_add_gem_socket" or "@ui_buyorder_add_perk"
    self.SelectButton:SetText(buttonText)
  end
end
function ContractBrowser_PerkSelector:SetIsGemSelector(isGemSelector)
  self.isGemSelector = isGemSelector
end
function ContractBrowser_PerkSelector:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function ContractBrowser_PerkSelector:GetIsGemSelector()
  return self.isGemSelector
end
function ContractBrowser_PerkSelector:HasSelection()
  return self.perkId and self.perkId >= 0
end
function ContractBrowser_PerkSelector:HasSpecificSelection()
  return self.perkId and self.perkId > 0
end
function ContractBrowser_PerkSelector:IsSelectButton()
  return self.perkId == self.SELECT_BUTTON_ID
end
function ContractBrowser_PerkSelector:SetCallbacks(selectCb, removeCb, cbTable)
  self.selectCb = selectCb
  self.removeCb = removeCb
  self.cbTable = cbTable
end
function ContractBrowser_PerkSelector:SetEnabled(isEnabled)
  if self.isEnabled == isEnabled then
    return
  end
  self.isEnabled = isEnabled
  self.SelectButton:SetEnabled(isEnabled)
end
function ContractBrowser_PerkSelector:OnSelect()
  if self.selectCb then
    self.selectCb(self.cbTable, self)
  end
end
function ContractBrowser_PerkSelector:OnRemove()
  if self.removeCb then
    self.removeCb(self.cbTable, self)
  end
end
function ContractBrowser_PerkSelector:OnFocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
end
function ContractBrowser_PerkSelector:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
end
function ContractBrowser_PerkSelector:OnRemoveButtonFocus()
  self.ScriptedEntityTweener:PlayC(self.Properties.RemoveButton, 0.15, tweenerCommon.fadeInQuadOut)
end
function ContractBrowser_PerkSelector:OnRemoveButtonUnfocus()
  self.ScriptedEntityTweener:PlayC(self.Properties.RemoveButton, 0.15, tweenerCommon.opacityTo30)
end
return ContractBrowser_PerkSelector
