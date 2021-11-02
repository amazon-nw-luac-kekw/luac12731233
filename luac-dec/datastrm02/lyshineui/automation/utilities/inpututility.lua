local InputQueue = RequireScript("LyShineUI.Automation.InputQueue")
local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = {
  MOUSE_BUTTONS = {LEFT_MOUSE_BUTTON = 1, RIGHT_MOUSE_BUTTON = 2},
  entityId = nil,
  heldKeys = {}
}
function InputUtility:PressKey(button)
  InputQueue:AddToQueue(function()
    Logger:Log("Pressing key: " .. button)
    UiAutomationBus.Broadcast.PressKey(button)
  end)
  self:ReleaseKey(button)
end
function InputUtility:HoldKey(button)
  InputQueue:AddToQueue(function()
    Logger:Log("Holding key: " .. button)
    UiAutomationBus.Broadcast.HoldKey(button)
    self.heldKeys[button] = true
  end)
end
function InputUtility:ReleaseKey(button)
  InputQueue:AddToQueue(function()
    Logger:Log("Releasing key: " .. button)
    UiAutomationBus.Broadcast.ReleaseKey(button)
    self.heldKeys[button] = nil
  end)
end
function InputUtility:TypeString(string)
  for i = 1, #string do
    InputQueue:AddToQueue(function()
      UiAutomationBus.Broadcast.PressKeyAscii(string.sub(string, i, i))
    end)
  end
end
function InputUtility:SetCursorPosition(pos)
  InputQueue:AddToQueue(function()
    Logger:Log("Setting cursor position: " .. tostring(pos))
    CursorBus.Broadcast.SetCursorPosition(pos)
  end)
end
function InputUtility:PressLeftClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Pressing left click")
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.LEFT_MOUSE_BUTTON)
  end)
end
function InputUtility:DoubleLeftClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Double left click")
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.LEFT_MOUSE_BUTTON)
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.LEFT_MOUSE_BUTTON)
  end)
end
function InputUtility:HoldLeftClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Holding left click")
    UiAutomationBus.Broadcast.HoldMouseButton(self.MOUSE_BUTTONS.LEFT_MOUSE_BUTTON)
  end)
end
function InputUtility:ReleaseLeftClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Releasing left click")
    UiAutomationBus.Broadcast.ReleaseMouseButton(self.MOUSE_BUTTONS.LEFT_MOUSE_BUTTON)
  end)
end
function InputUtility:PressRightClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Pressing right click")
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.RIGHT_MOUSE_BUTTON)
  end)
end
function InputUtility:DoubleRightClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Double right click")
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.RIGHT_MOUSE_BUTTON)
    UiAutomationBus.Broadcast.PressMouseButton(self.MOUSE_BUTTONS.RIGHT_MOUSE_BUTTON)
  end)
end
function InputUtility:HoldRightClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Holding right click")
    UiAutomationBus.Broadcast.HoldMouseButton(self.MOUSE_BUTTONS.RIGHT_MOUSE_BUTTON)
  end)
end
function InputUtility:ReleaseRightClick()
  InputQueue:AddToQueue(function()
    Logger:Log("Releasing right click")
    UiAutomationBus.Broadcast.ReleaseMouseButton(self.MOUSE_BUTTONS.RIGHT_MOUSE_BUTTON)
  end)
end
function InputUtility:Scroll(scrollDelta, ticks)
  for i = 1, ticks do
    InputQueue:AddToQueue(function()
      Logger:Log("Scrolling")
      UiAutomationBus.Broadcast.VerticalScroll(scrollDelta)
    end)
  end
end
function InputUtility:ClickAndDrag(pos1, pos2, release)
  self:SetCursorPosition(pos1)
  self:HoldLeftClick()
  self:SetCursorPosition(pos2)
  if release then
    self:ReleaseLeftClick()
  end
end
return InputUtility
