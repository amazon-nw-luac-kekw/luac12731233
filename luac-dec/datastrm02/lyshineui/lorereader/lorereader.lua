local LoreReader = {
  Properties = {
    TitleText = {
      default = EntityId()
    },
    MessageText = {
      default = EntityId()
    },
    EscapeButton = {
      default = EntityId()
    },
    BackgroundHolder = {
      default = EntityId()
    },
    DividerLine = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    ActionMapActivators = {
      default = {""}
    }
  },
  animOffsetPosX = 500
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LoreReader)
function LoreReader:OnInit()
  BaseScreen.OnInit(self)
  self.loreReaderComponentId = self.entityId
  self:BusConnect(LoreReaderNotificationsBus, self.loreReaderComponentId)
  self:SetVisualElements()
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  for k, v in pairs(self.Properties.ActionMapActivators) do
    self:BusConnect(CryActionNotificationsBus, v)
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  self.dataLayer:RegisterOpenEvent("LoreReader", self.canvasId)
  self:BusConnect(CryActionNotificationsBus, "toggleLoreReader")
end
function LoreReader:SetVisualElements()
  local titleTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 60,
    fontColor = self.UIStyle.COLOR_TAN
  }
  local messageTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 32,
    fontColor = self.UIStyle.COLOR_GRAY_70
  }
  SetTextStyle(self.TitleText, titleTextStyle)
  SetTextStyle(self.MessageText, messageTextStyle)
  self.DividerLine:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ScriptedEntityTweener:Set(self.DividerLine.entityId, {opacity = 0.7})
  self.EscapeButton:SetCallback(self.ExitClicked, self.entityId)
  self.EscapeButton:SetKeybindMapping("toggleMenuComponent")
  self.ScriptedEntityTweener:Set(self.entityId, {
    x = self.animOffsetPosX,
    opacity = 0
  })
end
function LoreReader:OnShowLoreReader(loreId)
  local loreData = LoreDataManagerBus.Broadcast.GetLoreData(loreId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, loreData.title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.MessageText, loreData.body, eUiTextSet_SetLocalized)
  LyShineManagerBus.Broadcast.SetState(3784122317)
end
function LoreReader:ExitClicked()
  LyShineManagerBus.Broadcast.ToggleState(3784122317)
end
function LoreReader:SetScreenVisible(isVisible)
  if isVisible then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_LoreReader", 0.4)
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 15
    self.targetDOFBlur = 0.4
    self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.5, {
      opacity = 1,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 1, ease = "QuadOut"})
    self.DividerLine:SetVisible(true, 0.8, {delay = 0.1})
  else
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_LoreReader", 0.5)
    self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.3, {
      opacity = 0,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end,
      onComplete = function()
        JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
      end
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      x = self.animOffsetPosX,
      ease = "QuadOut",
      onComplete = function()
        self:OnTransitionOutCompleted()
      end
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0, ease = "QuadOut"})
    self.DividerLine:SetVisible(false, 0.1)
  end
end
function LoreReader:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function LoreReader:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self:SetScreenVisible(true)
  self.escapeKeyHandler = CryActionNotificationsBus.Connect(self, "toggleMenuComponent")
  self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
  local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.vitalsNotification = self:BusConnect(VitalsComponentNotificationBus, vitalsId)
end
function LoreReader:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self:SetScreenVisible(false)
  self:BusDisconnect(self.vitalsNotification)
end
function LoreReader:OnTransitionOutCompleted()
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  self:BusDisconnect(self.escapeKeyHandler)
  self.escapeKeyHandler = nil
  self:BusDisconnect(self.interactKeyHandler)
  self.interactKeyHandler = nil
  LoreReaderRequestsBus.Broadcast.LoreReaderClosed()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function LoreReader:OnCryAction(actionName, value)
  if UiCanvasBus.Event.GetEnabled(self.canvasId) then
    local wasKeyPress = 0 < value
    if wasKeyPress then
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end
  end
end
function LoreReader:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasHeight(self.BackgroundHolder, self.canvasId)
  end
end
function LoreReader:OnDamage(attackerEntityId, healthPercentageLost, positionOfAttack, damageAngle, isSelfDamage, damageByType, isFromStatusEffect, cancelTargetHoming)
  if healthPercentageLost < GetEpsilon() then
    return
  end
  if positionOfAttack ~= nil then
    LyShineManagerBus.Broadcast.ExitState(3784122317)
  end
end
return LoreReader
