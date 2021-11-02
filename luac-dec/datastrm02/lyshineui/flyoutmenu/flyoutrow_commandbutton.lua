local FlyoutRow_CommandButton = {
  Properties = {
    Button = {
      default = EntityId()
    },
    IsFlyout = {default = false}
  },
  callback = nil,
  callbackTable = nil,
  callbackData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_CommandButton)
function FlyoutRow_CommandButton:OnInit()
  BaseElement.OnInit(self)
  self.originalButtonHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function FlyoutRow_CommandButton:OnShutdown()
end
function FlyoutRow_CommandButton:SetData(data)
  if not data then
    Log("[FlyoutRow_CommandButton] Error: invalid data passed to SetData")
    return
  end
  local textStyle = self.Properties.IsFlyout and self.UIStyle.FONT_STYLE_BUTTON_COMMAND_FLYOUT or self.UIStyle.FONT_STYLE_BUTTON_COMMAND
  self.Button:SetTextStyle(textStyle)
  self.Button:SetText(data.buttonText or "")
  self.Button:SetSecondaryText(data.secondaryText or "")
  self.Button:SetSecondaryTextHint(data.secondaryTextHint or nil)
  if data.tertiaryText and data.tertiaryText ~= "" then
    self.Button:SetTertiaryText(data.tertiaryText)
    if data.isDividerVisible ~= nil then
      self.Button:SetDividerVisible(data.isDividerVisible)
    else
      self.Button:SetDividerVisible(true)
    end
  else
    self.Button:SetTertiaryText("")
    self.Button:SetDividerVisible(false)
  end
  if data.color then
    self.Button:SetTextColor(data.color)
  end
  self.Button:SetIsDivider(data.isDivider)
  self.Button:SetBGColor(data.bgColor)
  if data.buttonHeight then
    self.Button:SetHeight(data.buttonHeight)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, data.buttonHeight)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, data.buttonHeight)
  else
    self.Button:SetHeight(self.originalButtonHeight)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.originalButtonHeight)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.originalButtonHeight)
  end
  if data.hint then
    self.Button:SetHint(data.hint, data.hintIsKeybind)
  end
  if data.tooltipInfo and (data.tooltipInfo.isRepair or data.tooltipInfo.isSalvage) and not self.Properties.IsFlyout then
    data.tooltipInfo.data = data
    if data.tooltipInfo.isRepair then
      if data.tooltipInfo.isRepairKit then
        self.Button:SetText("@ui_repair_kit")
      else
        self.Button:SetText("@inv_repair")
      end
    elseif data.tooltipInfo.isSalvage then
      self.Button:SetText("@inv_salvage")
    end
    self.Button:SetTertiaryText("")
    self.Button:SetDividerVisible(false)
    self.Button:SetHeight(self.originalButtonHeight)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.originalButtonHeight)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.originalButtonHeight)
  end
  if self.Properties.IsFlyout and data.tertiaryText and data.tertiaryText ~= "" then
    if data.tooltipInfo.isRepair then
      self.Button:SetWithText("@ui_with")
    elseif data.tooltipInfo.isSalvage then
      self.Button:SetWithText("@ui_into")
    end
  else
    self.Button:SetWithText(nil)
  end
  self.Button:SetTooltipInfo(data.tooltipInfo)
  self.Button:SetEnabled(not data.isDisabled)
  if data.bgImage then
    self.Button:SetButtonToListStyle(data.bgImage)
  end
  if data.secondaryTextStyle then
    self.Button:SetSecondaryTextStyle(data.secondaryTextStyle)
  else
    self.Button:SetSecondaryTextStyle(self.UIStyle.FONT_STYLE_TOOLTIP_BUTTON_COMMAND_SECONDARY_TEXT)
  end
  if data.secondaryTextIcon then
    self.Button:SetSecondaryTextIcon(data.secondaryTextIcon)
  else
    self.Button:SetSecondaryTextIcon(nil)
  end
  if data.textHeight then
    self.Button:SetTextHeight(data.textHeight)
  else
    self.Button:SetTextHeight(nil)
  end
  if data.textWidth then
    self.Button:SetTextWidth(data.textWidth)
  else
    self.Button:SetTextWidth(nil)
  end
  if data.tertiaryTextStyle then
    self.Button:SetTertiaryTextStyle(data.tertiaryTextStyle)
  else
    self.Button:SetTertiaryTextStyle(self.UIStyle.FONT_STYLE_TOOLTIP_BUTTON_COMMAND_TERTIARY_TEXT)
  end
  if data.isCrossVisible then
    self.Button:SetCrossVisible(data.isCrossVisible)
  else
    self.Button:SetCrossVisible(false)
  end
  if data.secondaryTextPosY then
    self.Button:SetSecondaryTextPosY(data.secondaryTextPosY)
  else
    self.Button:SetSecondaryTextPosY(nil)
  end
  if data.tertiaryTextPosY then
    self.Button:SetTertiaryTextPositionY(data.tertiaryTextPosY)
  else
    self.Button:SetTertiaryTextPositionY(nil)
  end
  self.stayOpenOnPress = data.stayOpenOnPress
  self:SetCallback(data.callback, data.callbackTable, data.callbackData)
  self.Button:SetCallback(self.OnButtonClick, self)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Button, true)
end
function FlyoutRow_CommandButton:SetCallback(command, table, data)
  self.callback = command
  self.table = table
  self.data = data
end
function FlyoutRow_CommandButton:ExecuteCallback()
  if self.callback and self.table then
    if type(self.callback) == "function" then
      self.callback(self.table, self.data)
    elseif type(self.table[self.callback]) == "function" then
      self.table[self.callback](self.table, self.data)
    end
  end
end
function FlyoutRow_CommandButton:OnButtonClick()
  self:ExecuteCallback()
  if not self.stayOpenOnPress then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Button, false)
    DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
  end
end
return FlyoutRow_CommandButton
