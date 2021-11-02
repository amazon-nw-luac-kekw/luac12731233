local RegionListItem = {
  Properties = {
    ItemTextLabel = {
      default = EntityId()
    },
    ItemImageData = {
      default = EntityId()
    },
    ItemPingText = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    ItemCharCount = {
      default = EntityId()
    }
  },
  mWidth = nil,
  mHeight = 40,
  mData = nil,
  mCallback = nil,
  mCallbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RegionListItem)
function RegionListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ItemTextLabel, self.UIStyle.FONT_STYLE_DROPDOWN)
  SetTextStyle(self.ItemPingText, self.UIStyle.FONT_STYLE_DROPDOWN)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
end
function RegionListItem:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function RegionListItem:GetWidth()
  return self.mWidth
end
function RegionListItem:GetHeight()
  return self.mHeight
end
function RegionListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextLabel, value, eUiTextSet_SetLocalized)
end
function RegionListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ItemTextLabel)
end
function RegionListItem:GetTextWidth()
  return UiTextBus.Event.GetTextSize(self.Properties.ItemTextLabel).x
end
function RegionListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, 2, {textColor = color})
end
function RegionListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ItemTextLabel, value)
end
function RegionListItem:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.Properties.ItemTextLabel, value)
end
function RegionListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ItemTextLabel, value)
end
function RegionListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ItemTextLabel)
end
function RegionListItem:SetTextStyle(value)
  SetTextStyle(self.Properties.ItemTextLabel, value)
end
function RegionListItem:SetImageData(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemImageData, value)
end
function RegionListItem:GetImageData()
  return data.image
end
function RegionListItem:SetPingText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemPingText, value, eUiTextSet_SetAsIs)
end
function RegionListItem:GetPingText()
  return UiTextBus.Event.GetText(self.Properties.ItemPingText)
end
function RegionListItem:SetData(data)
  self.mData = data
  if self.mData.image then
    self:SetImageData(self.mData.image)
  end
  if self.mData.latency then
    self:SetPingText(self.mData.latency)
  end
  if self.mData.numChars and self.mData.maxChars then
    UiTextBus.Event.SetText(self.Properties.ItemCharCount, tostring(self.mData.numChars) .. " / " .. tostring(self.mData.maxChars))
  end
end
function RegionListItem:GetData()
  return self.mData
end
function RegionListItem:OnFocus()
  self.ItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_DropdownListItem)
  if self.mData.owner then
    self.mData.owner:OnItemFocus(self.mData.itemIndex)
  end
end
function RegionListItem:OnUnfocus()
  self.ItemBg:OnUnfocus()
end
function RegionListItem:OnItemSelected()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.mCallback ~= nil and self.mCallbackTable ~= nil then
    self.mCallbackTable[self.mCallback](self.mCallbackTable, self.mData)
  end
end
function RegionListItem:OnShutdown()
end
function RegionListItem:SetCallback(command, table)
  self.mCallback = command
  self.mCallbackTable = table
end
return RegionListItem
