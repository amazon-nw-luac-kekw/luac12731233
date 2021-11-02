local WarningBar = {
  Properties = {
    WarningText = {
      default = EntityId()
    },
    RequestIntervalSeconds = {default = 60}
  },
  warningHeight = 0,
  isShowing = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarningBar)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function WarningBar:OnInit()
  BaseScreen.OnInit(self)
  self:CacheAnimations()
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.entityId, 0.6, {opacity = 0.6})
    self.timeline:Add(self.entityId, 1, {opacity = 1})
    self.timeline:Add(self.entityId, 1, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self:BusConnect(DynamicBus.UITickBus)
  self.progress = self.RequestIntervalSeconds
  self.currentWarning = ""
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.WorldWarning", self.SetWarning)
end
function WarningBar:CacheAnimations()
  self.warningHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  if not self.anim then
    self.anim = {}
    self.anim.showTo = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      y = 0,
      opacity = 1,
      ease = "QuadOut"
    })
    self.anim.hide = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      y = self.warningHeight,
      opacity = 0,
      ease = "QuadIn"
    })
  end
end
function WarningBar:OnTick(deltaTime, timePoint)
  self.progress = self.progress + deltaTime
  if self.progress > self.RequestIntervalSeconds then
    self.progress = self.progress - self.RequestIntervalSeconds
    DynamicContentBus.Broadcast.RetrieveWorldCMSWarning()
  end
end
function WarningBar:SetWarning(warning)
  if warning == self.currentWarning then
    return
  end
  self.currentWarning = warning
  if self.currentWarning == "" or self.currentWarning == nil then
    self.isShowing = false
    self:SetVisible(false, function()
      LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
    end)
    if self.timeline then
      self.timeline:Stop()
    end
  else
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
    if self.isShowing then
      self:SetVisible(false, function()
        self:SetVisible(true)
      end)
    else
      self:SetVisible(true)
    end
    self.isShowing = true
  end
end
function WarningBar:SetVisible(isVisible, callback)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {
      y = self.warningHeight,
      opacity = 0
    }, self.anim.showTo, nil, function()
      self.timeline:Play()
    end)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_System
    chatMessage.body = self.currentWarning
    UiTextBus.Event.SetText(self.Properties.WarningText, self.currentWarning)
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    self.audioHelper:PlaySound(self.audioHelper.Ingame_Server_Warning_Message)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.2, self.anim.hide, nil, function()
      if type(callback) == "function" then
        callback()
      end
    end)
  end
end
function WarningBar:OnShutdown()
  if self.timeline then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  BaseScreen.OnShutdown(self)
end
return WarningBar
