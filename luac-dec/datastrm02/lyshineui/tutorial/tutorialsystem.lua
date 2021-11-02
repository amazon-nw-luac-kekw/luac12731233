local TutorialSystem = {
  tutorials = {},
  tickHandler = nil,
  unboundKey = " "
}
local TutorialCommon = RequireScript("LyShineUI._Common.TutorialCommon")
function TutorialSystem:OnInit()
  self.requiredKeybinds = {}
  for actionMapName, keybinds in pairs(TutorialCommon.RequiredKeybinds) do
    for bindingName, _ in pairs(TutorialCommon.RequiredKeybinds[actionMapName]) do
      table.insert(self.requiredKeybinds, {bindingName = bindingName, actionMapName = actionMapName})
    end
  end
  self:CheckRequiredKeybinds()
end
function TutorialSystem:LoadTutorial(tutorialName)
  local tutorial = require("LyShineUI.Tutorial.Tutorial_" .. tutorialName)
  if tutorial then
    Debug.Log("Loaded Tutorial_" .. tutorialName)
    tutorial:OnInit()
    table.insert(self.tutorials, {table = tutorial, step = 1})
  else
    Debug.Log("Failed to Load Tutorial file: Tutorial_" .. tutorialName)
  end
  if not self.tickHandler then
    self.tickHandler = TickBus.Connect(self)
  end
end
function TutorialSystem:OnTick(elapsed, timepoint)
  for i, tutorial in ipairs(self.tutorials) do
    if tutorial.table.steps[tutorial.step](tutorial.table, elapsed) then
      tutorial.step = tutorial.step + 1
      if tutorial.step > #tutorial.table.steps then
        table.remove(self.tutorials, i)
      end
    end
  end
end
function TutorialSystem:OnShutdown()
  if self.tickHandler then
    self.tickHandler:Disconnect()
    self.tickHandler = nil
  end
  for _, tutorial in ipairs(self.tutorials) do
    tutorial.table:OnShutdown()
  end
  ClearTable(self.tutorials)
  self:ResetRequiredKeybinds()
end
function TutorialSystem:CheckRequiredKeybinds()
  for i = 1, #self.requiredKeybinds do
    local keybindData = self.requiredKeybinds[i]
    if not LyShineManagerBus.Broadcast.IsKeybindBound(keybindData.bindingName, keybindData.actionMapName) then
      GameRequestsBus.Broadcast.ResetActionMapAction(keybindData.bindingName, keybindData.actionMapName)
      keybindData.needsReset = true
    else
      keybindData.needsReset = nil
    end
  end
end
function TutorialSystem:ResetRequiredKeybinds()
  for i = 1, #self.requiredKeybinds do
    local keybindData = self.requiredKeybinds[i]
    if keybindData.needsReset then
      GameRequestsBus.Broadcast.RebindAction(keybindData.bindingName, keybindData.actionMapName, self.unboundKey)
      keybindData.needsReset = nil
    end
  end
end
return TutorialSystem
