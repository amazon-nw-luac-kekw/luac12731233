local GlobalStorageListItem = {
  Properties = {
    ItemTextLabel = {
      default = EntityId()
    },
    ItemImageData = {
      default = EntityId()
    },
    ItemTooltip = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    ItemHeaderBg = {
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
BaseElement:CreateNewElement(GlobalStorageListItem)
function GlobalStorageListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ItemTextLabel, self.UIStyle.FONT_STYLE_DROPDOWN)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
  self:SetImageData("")
end
function GlobalStorageListItem:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function GlobalStorageListItem:GetWidth()
  return self.mWidth
end
function GlobalStorageListItem:GetHeight()
  return self.mHeight
end
function GlobalStorageListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextLabel, value, eUiTextSet_SetLocalized)
end
function GlobalStorageListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ItemTextLabel)
end
function GlobalStorageListItem:GetTextWidth()
  return UiTextBus.Event.GetTextSize(self.Properties.ItemTextLabel).x
end
function GlobalStorageListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, 2, {textColor = color})
end
function GlobalStorageListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ItemTextLabel, value)
end
function GlobalStorageListItem:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.Properties.ItemTextLabel, value)
end
function GlobalStorageListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ItemTextLabel, value)
end
function GlobalStorageListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ItemTextLabel)
end
function GlobalStorageListItem:SetTextStyle(value)
  SetTextStyle(self.Properties.ItemTextLabel, value)
end
function GlobalStorageListItem:SetImageData(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemImageData, value)
end
function GlobalStorageListItem:GetImageData()
  return self.mData.image
end
function GlobalStorageListItem:SetStyle(styleName)
  if styleName == "TransferHeader" then
    self.mIsEnabled = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemImageData, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTextLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTooltip, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemHeaderBg, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemBg, false)
    SetTextStyle(self.Properties.ItemTextLabel, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  elseif styleName == "ViewOnlyHeader" then
    self.mIsEnabled = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemImageData, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTextLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTooltip, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemHeaderBg, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemBg, false)
    SetTextStyle(self.Properties.ItemTextLabel, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  elseif styleName == "Location" then
    self.mIsEnabled = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemImageData, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTextLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTooltip, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemHeaderBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemBg, true)
    SetTextStyle(self.ItemTextLabel, self.UIStyle.FONT_STYLE_DROPDOWN)
    UiTextBus.Event.SetColor(self.Properties.ItemTextLabel, self.UIStyle.COLOR_WHITE)
  end
end
function GlobalStorageListItem:SetData(data)
  self.mData = data
  if self.mData.image then
    self:SetImageData(self.mData.image)
  end
  if self.mData.style then
    self:SetStyle(self.mData.style)
  end
  if self.mData.text then
    self:SetText(self.mData.text)
  end
end
function GlobalStorageListItem:GetData()
  return self.mData
end
function GlobalStorageListItem:OnFocus()
  if self.mIsEnabled then
    self.ItemBg:OnFocus()
    self.audioHelper:PlaySound(self.audioHelper.OnHover_DropdownListItem)
    if self.mData.owner then
      self.mData.owner:OnItemFocus(self.mData.itemIndex)
    end
  end
end
function GlobalStorageListItem:OnUnfocus()
  if self.mIsEnabled then
    self.ItemBg:OnUnfocus()
  end
end
function GlobalStorageListItem:OnItemSelected()
  if self.mIsEnabled then
    self.audioHelper:PlaySound(self.audioHelper.Accept)
    if self.mCallback ~= nil and self.mCallbackTable ~= nil then
      self.mCallbackTable[self.mCallback](self.mCallbackTable, self.mData)
    end
  end
end
function GlobalStorageListItem:OnShutdown()
end
function GlobalStorageListItem:SetCallback(command, table)
  self.mCallback = command
  self.mCallbackTable = table
end
return GlobalStorageListItem
