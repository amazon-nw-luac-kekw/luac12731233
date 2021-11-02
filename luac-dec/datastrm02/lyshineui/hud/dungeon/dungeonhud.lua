local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local layouts = RequireScript("LyShineUI.Banner.Layouts")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local DungeonHud = {
  Properties = {
    EncounterTimer = {
      default = EntityId()
    },
    RemainingTimerHolder = {
      default = EntityId()
    },
    RemainingTimerText = {
      default = EntityId()
    }
  },
  dataLayer_countdownTimerId = "Timer_" .. tostring(780009316),
  REMAINING_TIME_THRESHOLD = 300,
  TIMER_TICK = 1,
  TIMER = 0,
  DUNGEON_EXPIRE_FADE_IN_TIME = 1.5
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
BaseScreen:CreateNewScreen(DungeonHud)
function DungeonHud:OnInit()
  BaseScreen.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
      self:BusDisconnect(self.participantBusHandler)
      self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead then
      self.isDead = true
    else
      self.isDead = false
    end
  end)
end
function DungeonHud:OnTick(deltaTime, timePoint)
  if self.dungeonActive then
    self.TIMER = self.TIMER + deltaTime
    if self.TIMER >= self.TIMER_TICK then
      self.TIMER = self.TIMER - self.TIMER_TICK
      if self.groupId and self.groupId:IsValid() then
        local dungeonRemainingTime = GroupDataRequestBus.Event.GetDungeonRemainingEnterTime(self.groupId)
        if dungeonRemainingTime <= self.REMAINING_TIME_THRESHOLD and dungeonRemainingTime ~= nil then
          local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(dungeonRemainingTime)
          local timerText = string.format("%d:%02d", minutes, seconds)
          UiTextBus.Event.SetTextWithFlags(self.Properties.RemainingTimerText, timerText, eUiTextSet_SetLocalized)
          if not self.remainingTimerEnabled then
            self.remainingTimerEnabled = true
            UiElementBus.Event.SetIsEnabled(self.Properties.RemainingTimerHolder, true)
            UiElementBus.Event.SetIsEnabled(self.Properties.RemainingTimerText, true)
            self.ScriptedEntityTweener:Play(self.Properties.RemainingTimerHolder, self.DUNGEON_EXPIRE_FADE_IN_TIME, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
            self.ScriptedEntityTweener:Play(self.Properties.RemainingTimerText, self.DUNGEON_EXPIRE_FADE_IN_TIME, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
          end
        end
      end
    end
  end
end
function DungeonHud:SetTicking(isTicking)
  if isTicking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function DungeonHud:GetGameModeDataPath(gameModeEntityId, valueName)
  return "GameMode." .. tostring(gameModeEntityId) .. "." .. valueName
end
function DungeonHud:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function DungeonHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady", function(self, isReady)
    if not isReady then
      return
    end
    local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.localPlayerEntityId, gameModeId)
    if not gameModeData.isDungeon then
      return
    end
    self.remainingTimerEnabled = false
    self.dungeonActive = true
    self:SetTicking(true)
    self.groupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    self.victoryDelayTime = gameModeData.victoryDelaySec
    self.gameModeEntityId = gameModeEntityId
    self.gameModeData = gameModeData
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.EncounterTimer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingTimerHolder, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingTimerText, false)
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_countdownTimerId), function(self, timeRemaining)
      if not timeRemaining then
        return
      end
      UiElementBus.Event.SetIsEnabled(self.entityId, true)
      local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 1)
      if 1 < secondsRemaining then
        UiElementBus.Event.SetIsEnabled(self.Properties.EncounterTimer, true)
        local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
        local timerText = string.format("%d:%02d", minutes, seconds)
        UiTextBus.Event.SetText(self.Properties.EncounterTimer, timerText)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.EncounterTimer, false)
      end
    end)
    if self.objectivesComponentBusHandler then
      self:BusDisconnect(self.objectivesComponentBusHandler)
    end
    self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.localPlayerEntityId)
  end)
end
function DungeonHud:OnExitedGameMode(gameModeEntityId)
  if self.gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  self.dungeonActive = false
  self:SetTicking(false)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_countdownTimerId))
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady")
  self:BusDisconnect(self.objectivesComponentBusHandler)
end
function DungeonHud:OnSecondToLastDungeonTaskCompleted()
  TimingUtils:Delay(self.victoryDelayTime, self, function()
    if not self.isDead then
      DynamicBus.RewardScreen.Broadcast.OnDungeonCompletion()
    end
  end)
end
return DungeonHud
