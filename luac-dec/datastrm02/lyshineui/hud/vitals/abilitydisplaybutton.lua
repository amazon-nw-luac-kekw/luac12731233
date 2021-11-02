local AbilityDisplayButton = {
  Properties = {
    IconBg = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    }
  },
  iconPathRoot = "lyShineui/images/icons/abilities/"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilityDisplayButton)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local AbilitiesCommon = RequireScript("LyShineUI._Common.AbilitiesCommon")
function AbilityDisplayButton:OnInit()
  local flyoutMenu = RequireScript("LyShineUI.FlyoutMenu.FlyoutMenu")
  self.flyoutWarningRow = {
    type = flyoutMenu.ROW_TYPE_Label,
    backgroundPath = "",
    backgroundColor = self.UIStyle.COLOR_RED_DEEP,
    text = "@ui_abilitynotunlocked",
    textColor = self.UIStyle.COLOR_RED_MEDIUM
  }
  self.flyoutAbilityRow = {
    type = flyoutMenu.ROW_TYPE_Ability
  }
end
function AbilityDisplayButton:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function AbilityDisplayButton:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function AbilityDisplayButton:GetHorizontalSpacing()
  return 20
end
function AbilityDisplayButton:SetGridItemData(gridItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if gridItemData then
    self:SetDisplayData(gridItemData.displayName, gridItemData.displayIcon, gridItemData.displayDescription, gridItemData.cooldownTime, gridItemData.isAbilityUnlocked, gridItemData.uiCategory)
    UiImageBus.Event.SetColor(self.Properties.Icon, gridItemData.isAbilityUnlocked and self.UIStyle.COLOR_GRAY_80 or self.UIStyle.COLOR_GRAY_30)
    UiImageBus.Event.SetColor(self.Properties.IconBg, gridItemData.isAbilityUnlocked and self.UIStyle.COLOR_GRAY_80 or self.UIStyle.COLOR_GRAY_30)
    self:SetAbilityClickedCallback(gridItemData.callbackSelf, gridItemData.onClickCallback)
    self.callbackData = gridItemData
  end
end
function AbilityDisplayButton:SetDisplayData(displayName, displayIcon, displayDescription, cooldownTime, isAbilityUnlocked, uiCategory)
  displayIcon = self.iconPathRoot .. displayIcon .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, displayIcon)
  local bgPath = AbilitiesCommon:GetBackgroundPath(uiCategory)
  UiImageBus.Event.SetSpritePathname(self.Properties.IconBg, bgPath)
  self.cooldownTime = cooldownTime
  self.displayIcon = displayIcon
  self.displayName = displayName
  self.displayDescription = displayDescription
  self.isAbilityUnlocked = isAbilityUnlocked
end
function AbilityDisplayButton:SetAbilityClickedCallback(callbackSelf, callbackFunction)
  self.callbackSelf = callbackSelf
  self.callbackFunction = callbackFunction
end
function AbilityDisplayButton:OnAbilityFocus()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  self.flyoutAbilityRow.abilityName = self.displayName
  self.flyoutAbilityRow.abilityIcon = self.displayIcon
  self.flyoutAbilityRow.cooldownTime = tostring(self.cooldownTime)
  self.flyoutAbilityRow.abilityDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(self.displayDescription)
  self.flyoutAbilityRow.isAbilityUnlocked = self.isAbilityUnlocked
  if not self.isAbilityUnlocked then
    table.insert(rows, self.flyoutWarningRow)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, 0.3, tweenerCommon.imgToWhite)
    self.ScriptedEntityTweener:PlayC(self.Properties.IconBg, 0.3, tweenerCommon.imgToWhite)
  end
  table.insert(rows, self.flyoutAbilityRow)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:EnableFlyoutDelay(true)
  flyoutMenu:SetRowData(rows)
end
function AbilityDisplayButton:OnAbilityUnfocus()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if self.isAbilityUnlocked then
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, 0.3, tweenerCommon.imgToGray80)
    self.ScriptedEntityTweener:PlayC(self.Properties.IconBg, 0.3, tweenerCommon.imgToGray80)
  end
end
function AbilityDisplayButton:OnAbilityClicked()
  if self.callbackFunction then
    self.callbackFunction(self.callbackSelf, self.callbackData)
  end
end
return AbilityDisplayButton
