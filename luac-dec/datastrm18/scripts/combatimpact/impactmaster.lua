ImpactTable = {
  Properties = {}
}
local PaperdollUtils = RequireScript("Scripts.Utils.PaperdollUtils")
require("Scripts.CombatImpact.impactdebug")
require("Scripts.CombatImpact.sword")
require("Scripts.CombatImpact.club")
require("Scripts.CombatImpact.axe")
require("Scripts.CombatImpact.greataxe")
require("Scripts.CombatImpact.unarmed")
require("Scripts.CombatImpact.musket")
require("Scripts.CombatImpact.bow")
require("Scripts.CombatImpact.LifeStaff")
require("Scripts.CombatImpact.FireStaff")
require("Scripts.CombatImpact.FlameThrower")
require("Scripts.CombatImpact.demohammer")
require("Scripts.CombatImpact.arrow")
require("Scripts.CombatImpact.bullet")
require("Scripts.CombatImpact.shield")
require("Scripts.CombatImpact.spear")
require("Scripts.CombatImpact.npc_specific")
require("Scripts.CombatImpact.Magic_ElemFire")
require("Scripts.CombatImpact.WarHammer")
require("Scripts.CombatImpact.IceGauntlet")
require("Scripts.CombatImpact.Structure")
function ImpactTable:OnActivate()
  self.notificationBusHandler = ImpactNotificationBus.Connect(self, self.entityId)
end
function ImpactTable:OnDeactivate()
  self.notificationBusHandler:Disconnect()
end
function ImpactTable:OnImpact(funcName, impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId, isBlocked)
  if ImpactTable[funcName] then
    ImpactTable[funcName](ImpactTable, impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId, isBlocked)
  else
    Debug.Log(false, "##### Impact Tables - Unable to find function " .. funcName)
  end
end
return ImpactTable
