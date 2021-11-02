local Tutorial_MasteryTree = {
  steps = {},
  WhirlingBladeUnlocked = false,
  WhirlingBlade = 248953190,
  SwordRushCRC = 655891104,
  busHandler = nil,
  ActiveSkillUnlocked = false
}
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local audioHelper = RequireScript("LyShineUI.AudioEvents")
function Tutorial_MasteryTree:OnInit()
  self.audioHelper = audioHelper
  self.steps = {
    self.WaitForBanner,
    self.WaitUntilSkillState,
    self.WaitUntilMasteryTreeOpened,
    self.WaitForPointSelection,
    self.WaitForAbilityMsg,
    self.WaitForScreenToBeClosed
  }
  DataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
      self.busHandler = ProgressionPointsNotificationBus.Connect(self, playerEntityId)
    end
  end)
  self.ActiveSkillUnlocked = false
end
function Tutorial_MasteryTree:OnShutdown()
  self.playerEntityId = nil
  if self.busHandler then
    self.busHandler:Disconnect()
    self.busHandler = nil
  end
end
function Tutorial_MasteryTree:WaitForBanner(elapsed)
  if not self.playerEntityId then
    return false
  end
  local points = ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, 3907802902) or 0
  if points == 0 then
    return false
  end
  DynamicBus.FtueMessageBus.Broadcast.SetMasteryTutorialActive(true)
  DynamicBus.FtueMessageBus.Broadcast.SetElementVisibleForTutorial(false)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockCombat", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockSkills", false)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockJournal", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", true)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", true)
  DynamicBus.TutorialMessageLarge.Broadcast.OnTutorialLargeDeactivated(false)
  DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("MasteryBanner", 2)
  LyShineManagerBus.Broadcast.EnableWorldHitUIAction(false)
  return true
end
function Tutorial_MasteryTree:WaitUntilSkillState(elapsed)
  if LyShineManagerBus.Broadcast.GetCurrentState() == 3576764016 then
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockCombat", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockSkills", true)
    DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("MasteryTreeSelect")
    self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
    return true
  else
    return false
  end
end
function Tutorial_MasteryTree:WaitUntilMasteryTreeOpened(elapsed)
  local isVisible = DynamicBus.MasteryTree.Broadcast.GetVisible()
  if isVisible then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("MasterySkillSelect")
    self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
  end
  return isVisible
end
function Tutorial_MasteryTree:WaitForPointSelection(elapsed)
  if self.ActiveSkillUnlocked then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    DynamicBus.FocusOverlayBus.Broadcast.ShowOverlay("MasteryEquipRemind")
    self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
    self.timer = 0
  end
  return self.ActiveSkillUnlocked
end
function Tutorial_MasteryTree:WaitForAbilityMsg(elapsed)
  self.timer = self.timer + elapsed
  if self.timer > 1 then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("@TUT_Mastery_Close", true, "@TUT_Title_Mastery", false, false, 2, {
      "toggleMenuComponent"
    }, {"ui"}, {}, 460, 200)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockSkills", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", false)
    DynamicBus.FocusOverlayBus.Broadcast.OnTutorialStopFocusUIElement()
    return true
  end
  return false
end
function Tutorial_MasteryTree:WaitForScreenToBeClosed(elapsed)
  local inSkills = LyShineManagerBus.Broadcast.GetCurrentState() == 3576764016
  if not inSkills then
    DynamicBus.TutorialMessage.Broadcast.OnTutorialDeactivated()
    DynamicBus.FtueMessageBus.Broadcast.SetMasteryTutorialActive(false)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockJournal", false)
    LyShineManagerBus.Broadcast.EnableWorldHitUIAction(true)
  end
  return not inSkills
end
function Tutorial_MasteryTree:OnProgressionPointsChanged(pointId, oldLevel, newLevel)
  if (pointId == self.WhirlingBlade or pointId == self.SwordRushCRC) and 0 < newLevel then
    self.ActiveSkillUnlocked = true
  end
end
return Tutorial_MasteryTree
