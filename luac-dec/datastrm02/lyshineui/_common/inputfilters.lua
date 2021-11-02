local InputFilters = {
  filterNames = {
    "LockInventory",
    "LockWeapons",
    "LockQuickslots",
    "LockCombat",
    "LockSkills",
    "LockEscMenu",
    "LockJournal",
    "LockAutorun",
    "LockEmotes",
    "LockCamping",
    "LockMenus"
  }
}
function InputFilters:OnActivate()
  for _, filter in ipairs(self.filterNames) do
    UIInputRequestsBus.Broadcast.CreateInputFilter(filter)
  end
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockInventory", "toggleInventoryWindow")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockInventory", "toggleMenuComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "sheathe")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "quickslot-weapon1")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "quickslot-weapon2")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "quickslot-weapon3")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "attack_primary")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockWeapons", "attack_primary_hold")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockQuickslots", "quickslot-consumable-1")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockQuickslots", "quickslot-consumable-2")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockQuickslots", "quickslot-consumable-3")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockQuickslots", "quickslot-consumable-4")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "sprint")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "jump")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "attack_special")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "moveleft")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "moveright")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "moveforward")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "moveback")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "autorun")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "dodge")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "dodge_depressed")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCombat", "block")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockSkills", "toggleSkillsComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockSkills", "toggleMenuComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockEscMenu", "ui_cancel")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockJournal", "toggleJournalComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockAutorun", "autorun")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockEmotes", "toggleEmoteWindow")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCamping", "makeCampOn")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockCamping", "makeCampOff")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "ui_cancel")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleMenuComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleInventoryWindow")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleGuildComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleWarboardInGame")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleJournalComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleMapComponent")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleRaidWindow")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleSocialWindow")
  UIInputRequestsBus.Broadcast.AddActionToInputFilter("LockMenus", "toggleEmoteWindow")
end
function InputFilters:Reset()
  for _, filter in ipairs(self.filterNames) do
    UIInputRequestsBus.Broadcast.EnableInputFilter(filter, false)
  end
end
return InputFilters
