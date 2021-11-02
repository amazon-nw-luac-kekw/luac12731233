local FullscreenAssert = {
  Properties = {
    AssertText = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FullscreenAssert)
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
function FullscreenAssert:OnInit()
  BaseScreen.OnInit(self)
  self.assertStack = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.fullscreenAssertOnLogs", function(self, enableAsserts)
    self.assertOnLogs = enableAsserts
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enableFullscreenAsserts", function(self, enableAsserts)
    self.enableAsserts = enableAsserts
    self:UpdateAsserts()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.outputScriptErrorsToChat", function(self, enableAsserts)
    self.chatAsserts = enableAsserts
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Debug.Asserts.CustomValue", function(self, assertValue)
    if not assertValue then
      return
    end
    self:AddAssert(assertValue)
  end)
  local chatMessage = BaseGameChatMessage()
  chatMessage.type = eChatMessageType_System
  chatMessage.showInFtue = true
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Debug.Asserts.Value", function(self, assertValue)
    if not assertValue then
      return
    end
    if self.assertOnLogs or assertValue:find("START STACK TRACE") then
      self:AddAssert(assertValue)
    end
    if self.chatAsserts then
      chatMessage.body = assertValue
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    end
  end)
  local mapTextureSizePadding = 32
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Debug.Asserts.TextureBudgetOverflow", function(self, assertValue)
    if assertValue and LyShineManagerBus.Broadcast.GetCurrentState() ~= 2477632187 then
      assertValue = assertValue + mapTextureSizePadding
    end
    if not assertValue or assertValue <= 0 then
      return
    end
    self:AddAssert(string.format("Texture budget over by %d MB", assertValue))
  end)
end
function FullscreenAssert:AddAssert(assertText)
  if not self.enableAsserts then
    return
  end
  local isNewAssert = true
  for _, assertData in ipairs(self.assertStack) do
    if assertData.text == assertText then
      assertData.count = assertData.count + 1
      isNewAssert = false
      break
    end
  end
  if isNewAssert then
    table.insert(self.assertStack, {text = assertText, count = 0})
  end
  self:UpdateAsserts()
end
function FullscreenAssert:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function FullscreenAssert:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self.isShowing = true
  cryActionCommon:RegisterActionListener(self, "ui_cancel", 0, self.OnCryAction)
end
function FullscreenAssert:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.isShowing = false
  cryActionCommon:UnregisterActionListener(self, "ui_cancel")
  self:UpdateAsserts()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function FullscreenAssert:UpdateAsserts()
  if not self.enableAsserts then
    return
  end
  if not self.isShowing and #self.assertStack > 0 then
    local assertData = self.assertStack[1]
    table.remove(self.assertStack, 1)
    local displayText = assertData.text
    if 0 < assertData.count then
      displayText = displayText .. " x" .. tostring(assertData.count + 1)
    end
    UiTextBus.Event.SetText(self.Properties.AssertText, displayText)
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
  end
end
function FullscreenAssert:OnClose()
  LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
end
function FullscreenAssert:OnCryAction(actionName, value)
  if 0 < value then
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  end
end
return FullscreenAssert
