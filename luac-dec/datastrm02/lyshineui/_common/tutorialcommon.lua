local TutorialCommon = {}
TutorialCommon.RequiredKeybinds = {
  movement = {
    moveforward = true,
    moveforward_onpress = true,
    moveback = true,
    moveback_onpress = true,
    moveleft = true,
    moveleft_onpress = true,
    moveright = true,
    moveright_onpress = true,
    crouch_toggle = true
  },
  player = {
    sheathe = true,
    block = true,
    attack_primary = true,
    attack_primary_hold = true,
    dodge = true
  },
  ui = {
    ui_interact = true,
    toggleInventoryWindow = true,
    ["quickslot-consumable-1"] = true,
    ["quickslot-consumable-2"] = true,
    toggleSkillsComponent = true
  }
}
function TutorialCommon:IsKeybindRequiredForFtue(bindingName, actionMapName)
  return self.RequiredKeybinds[actionMapName] and self.RequiredKeybinds[actionMapName][bindingName]
end
return TutorialCommon
