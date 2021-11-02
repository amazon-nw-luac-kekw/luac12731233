local Toggle = {
  Properties = {
    ToggleRadioGroup = {
      default = EntityId()
    },
    ToggleButton1 = {
      default = EntityId()
    },
    ToggleButton2 = {
      default = EntityId()
    },
    ToggleBg = {
      default = EntityId()
    },
    ToggleFrame = {
      default = EntityId()
    }
  },
  mWidth = 0,
  mHeight = 0,
  mDataLayerPath = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Toggle)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function Toggle:OnInit()
  BaseElement.OnInit(self)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetWidth(self.mWidth)
  self.ToggleButton1:OnInit()
  self.ToggleButton2:OnInit()
  self.ScriptedEntityTweener:Set(self.Properties.ToggleBg, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_DARKER_ORANGE
  })
end
function Toggle:ToggleState(isActive, isInitialization)
  local button = self.ToggleButton1
  local otherButton = self.ToggleButton2
  if isActive == true then
    button = self.ToggleButton2
    otherButton = self.ToggleButton1
  end
  local state = UiRadioButtonBus.Event.GetState(button.entityId)
  if not state then
    UiRadioButtonGroupBus.Event.SetState(self.ToggleRadioGroup, button.entityId, true)
    if isInitialization then
      button:Init(isInitialization)
    else
      button:OnSelected()
    end
    otherButton:OnUnselected()
  end
end
function Toggle:InitToggleState(isActive)
  self:ToggleState(isActive, true)
end
function Toggle:SetToggleState(isActive)
  self:ToggleState(isActive, false)
end
function Toggle:SetDisabled(disabled)
  local bgColor = disabled and self.UIStyle.COLOR_GRAY_DARK or self.UIStyle.COLOR_DARKER_ORANGE
  local animDuration = 0.2
  self.ScriptedEntityTweener:Play(self.Properties.ToggleBg, animDuration, {
    opacity = 1,
    imgColor = bgColor,
    ease = "QuadOut"
  })
  self.ToggleButton1:SetDisabled(disabled)
  self.ToggleButton2:SetDisabled(disabled)
end
function Toggle:SetDataNode(dataNode)
  if dataNode and type(dataNode) == "string" then
    if not self.dataLayer then
      self.dataLayer = dataLayer
    end
    self.dataLayer:RegisterDataObserver(self, dataNode, function(self, option)
      self:InitToggleState(option)
    end)
  end
end
function Toggle:SetEnablingDataNode(dataNode)
  if dataNode and type(dataNode) == "string" then
    if not self.dataLayer then
      self.dataLayer = dataLayer
    end
    self.dataLayer:RegisterAndExecuteDataObserver(self, dataNode, function(self, option)
      self:SetDisabled(not option)
    end)
  end
end
function Toggle:SetCallbackButton1(command, table)
  self.ToggleButton1:SetCallback(command, table)
end
function Toggle:SetCallbackButton2(command, table)
  self.ToggleButton2:SetCallback(command, table)
end
function Toggle:SetCallback(command1, command2, table)
  self.ToggleButton1:SetCallback(command1, table)
  self.ToggleButton2:SetCallback(command2, table)
end
function Toggle:SetText(buttonText1, buttonText2)
  self.ToggleButton1:SetText(buttonText1)
  self.ToggleButton2:SetText(buttonText2)
end
function Toggle:SetTextButton1(value)
  self.ToggleButton1:SetText(value)
end
function Toggle:SetTooltipButton1(value)
  self.ToggleButton1:SetTooltip(value)
end
function Toggle:SetTextButton2(value)
  self.ToggleButton2:SetText(value)
end
function Toggle:SetTooltipButton2(value)
  self.ToggleButton2:SetTooltip(value)
end
function Toggle:GetTextButton1()
  return self.ToggleButton1:GetText()
end
function Toggle:GetTextButton2()
  return self.ToggleButton2:GetText()
end
function Toggle:GetStateButton1()
  return UiRadioButtonBus.Event.GetState(self.ToggleButton1.entityId)
end
function Toggle:GetStateButton2()
  return UiRadioButtonBus.Event.GetState(self.ToggleButton2.entityId)
end
function Toggle:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function Toggle:SetWidth(width)
  self.mWidth = width
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
end
function Toggle:SetHeight(height)
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function Toggle:GetWidth()
  return self.mWidth
end
function Toggle:GetHeight()
  return self.mHeight
end
function Toggle:SetLineColor(color)
  UiImageBus.Event.SetColor(self.Properties.ToggleFrame, color)
end
function Toggle:OnShutdown()
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
  end
end
return Toggle
