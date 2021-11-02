local DropdownListItem = {
  Properties = {
    ItemTextLabel = {
      default = EntityId()
    },
    ItemTextData = {
      default = EntityId()
    },
    ListItemBg = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  mWidth = nil,
  mHeight = 40,
  mData = nil,
  mCallback = nil,
  mCallbackTable = nil,
  mIsEnabled = true,
  mIsAnimating = false,
  mIsUsingTooltip = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DropdownListItem)
function DropdownListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ItemTextLabel, self.UIStyle.FONT_STYLE_DROPDOWN)
  SetTextStyle(self.ItemTextData, self.UIStyle.FONT_STYLE_DROPDOWN)
  self.textLabelColorFocus = self.UIStyle.COLOR_WHITE
  self.textLabelColorUnfocus = self.UIStyle.COLOR_GRAY_50
  self.textDataColorFocus = self.UIStyle.COLOR_WHITE
  self.textDataColorUnfocus = self.UIStyle.COLOR_GRAY_90
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.textLabelOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.ItemTextLabel)
  self:SetSize(self.mWidth, self.mHeight)
  self:SetTextData("")
end
function DropdownListItem:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function DropdownListItem:GetWidth()
  return self.mWidth
end
function DropdownListItem:GetHeight()
  return self.mHeight
end
function DropdownListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextLabel, value, eUiTextSet_SetLocalized)
  self:AdjustTextSize()
end
function DropdownListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ItemTextLabel)
end
function DropdownListItem:GetTextWidth()
  return UiTextBus.Event.GetTextSize(self.Properties.ItemTextLabel).x
end
function DropdownListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, 2, {textColor = color})
end
function DropdownListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ItemTextLabel, value)
end
function DropdownListItem:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.Properties.ItemTextLabel, value)
end
function DropdownListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ItemTextLabel, value)
end
function DropdownListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ItemTextLabel)
end
function DropdownListItem:SetTextStyle(value)
  SetTextStyle(self.Properties.ItemTextLabel, value)
end
function DropdownListItem:SetTextData(value)
  UiTextBus.Event.SetText(self.Properties.ItemTextData, value)
  self:AdjustTextSize()
end
function DropdownListItem:GetTextData()
  return UiTextBus.Event.GetText(self.Properties.ItemTextData)
end
function DropdownListItem:AdjustTextSize()
  local offsets = UiOffsets(self.textLabelOffsets.left, self.textLabelOffsets.top, self.textLabelOffsets.right, self.textLabelOffsets.bottom)
  if self:GetTextData() == "" then
    offsets.right = 0
  end
  UiTransform2dBus.Event.SetOffsets(self.Properties.ItemTextLabel, offsets)
end
function DropdownListItem:SetEnabled(isEnabled)
  self.mIsEnabled = isEnabled
end
function DropdownListItem:SetIsAnimating(isAnimating)
  self.mIsAnimating = isAnimating
end
function DropdownListItem:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function DropdownListItem:SetData(data)
  self.mData = data
end
function DropdownListItem:GetData()
  return self.mData
end
function DropdownListItem:OnFocus()
  if self.mIsUsingTooltip and not self.mIsAnimating then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.mIsEnabled then
    return
  end
  local animDuration1 = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, animDuration1, {
    textColor = self.textLabelColorFocus
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextData, animDuration1, {
    textColor = self.textDataColorFocus
  })
  self.ListItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_DropdownListItem)
  if self.mData.owner then
    self.mData.owner:OnItemFocus(self.mData.itemIndex)
  end
end
function DropdownListItem:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  local animDuration1 = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, animDuration1, {
    textColor = self.textLabelColorUnfocus
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextData, animDuration1, {
    textColor = self.textDataColorUnfocus
  })
  self.ListItemBg:OnUnfocus()
end
function DropdownListItem:OnItemSelected()
  if not self.mIsEnabled then
    return
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.mIsEnabled and self.mCallback ~= nil and self.mCallbackTable ~= nil then
    self.mCallbackTable[self.mCallback](self.mCallbackTable, self.mData)
  end
end
function DropdownListItem:OnShutdown()
end
function DropdownListItem:SetCallback(command, table)
  self.mCallback = command
  self.mCallbackTable = table
end
return DropdownListItem
