local WarboardCommon = {}
WarboardCommon.statsShown = {}
WarboardCommon.performanceStats = {}
WarboardCommon.topStats = {}
WarboardCommon.statsShown[0] = {
  {
    stat = nil,
    loc = "@ui_war_rank"
  },
  {
    stat = nil,
    loc = "@ui_war_eom_sort_button_name"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Score,
    loc = "@ui_war_eom_sort_button_score"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Kills,
    loc = "@ui_war_eom_sort_button_kills"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Deaths,
    loc = "@ui_war_eom_sort_button_deaths"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Assists,
    loc = "@ui_war_eom_sort_button_assists"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_HealingDone,
    loc = "@ui_war_eom_sort_button_healing"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_TotalDamageDealt,
    loc = "@ui_war_eom_sort_button_damage"
  }
}
WarboardCommon.statsShown[2444859928] = {
  {
    stat = nil,
    loc = "@ui_war_rank"
  },
  {
    stat = nil,
    loc = "@ui_war_eom_sort_button_name"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Score,
    loc = "@ui_war_eom_sort_button_score"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_PlayerKills,
    loc = "@ui_war_eom_sort_button_player_kills"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_AITakedowns,
    loc = "@ui_war_eom_sort_button_npc_kills"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_Deaths,
    loc = "@ui_war_eom_sort_button_deaths"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_PlayerAssists,
    loc = "@ui_war_eom_sort_button_assists"
  },
  {
    stat = WarboardStatsEntry.eWarboardStatType_TotalResourcesDeposited,
    loc = "@ui_war_eom_sort_button_total_resources_deposited"
  }
}
WarboardCommon.performanceStats[0] = {
  WarboardStatsEntry.eWarboardStatType_TotalDamageDealt,
  WarboardStatsEntry.eWarboardStatType_DamageTaken,
  WarboardStatsEntry.eWarboardStatType_Kills,
  WarboardStatsEntry.eWarboardStatType_HealingDone,
  WarboardStatsEntry.eWarboardStatType_Assists,
  WarboardStatsEntry.eWarboardStatType_Deaths,
  WarboardStatsEntry.eWarboardStatType_DamageWithWeapons,
  WarboardStatsEntry.eWarboardStatType_DamageWithSiegeWeapons,
  WarboardStatsEntry.eWarboardStatType_KillsWithWeapons,
  WarboardStatsEntry.eWarboardStatType_KillsWithSiegeWeapons,
  WarboardStatsEntry.eWarboardStatType_DamageFromWeapons,
  WarboardStatsEntry.eWarboardStatType_DamageFromSiegeWeapons,
  WarboardStatsEntry.eWarboardStatType_SiegeWeaponsDestroyed,
  WarboardStatsEntry.eWarboardStatType_SiegeWeaponReloaded,
  WarboardStatsEntry.eWarboardStatType_AlliesRevived,
  WarboardStatsEntry.eWarboardStatType_RepairsDone,
  WarboardStatsEntry.eWarboardStatType_HealingDoneToSelf,
  WarboardStatsEntry.eWarboardStatType_HealingDoneToAllies
}
WarboardCommon.performanceStats[2444859928] = {
  WarboardStatsEntry.eWarboardStatType_PlayerKills,
  WarboardStatsEntry.eWarboardStatType_AIKills,
  WarboardStatsEntry.eWarboardStatType_Deaths,
  WarboardStatsEntry.eWarboardStatType_AIAssists,
  WarboardStatsEntry.eWarboardStatType_PlayerAssists,
  WarboardStatsEntry.eWarboardStatType_AITakedowns,
  WarboardStatsEntry.eWarboardStatType_PlayerTakedowns,
  WarboardStatsEntry.eWarboardStatType_AlliesRevived,
  WarboardStatsEntry.eWarboardStatType_InfusedWoodGathered,
  WarboardStatsEntry.eWarboardStatType_InfusedOreGathered,
  WarboardStatsEntry.eWarboardStatType_InfusedHideGathered,
  WarboardStatsEntry.eWarboardStatType_InfusedWoodDeposited,
  WarboardStatsEntry.eWarboardStatType_InfusedOreDeposited,
  WarboardStatsEntry.eWarboardStatType_InfusedHideDeposited,
  WarboardStatsEntry.eWarboardStatType_TotalResourcesDeposited,
  WarboardStatsEntry.eWarboardStatType_DamageWithWeapons,
  WarboardStatsEntry.eWarboardStatType_DamageWithSiegeWeapons,
  WarboardStatsEntry.eWarboardStatType_TotalDamageDealt,
  WarboardStatsEntry.eWarboardStatType_HealingDoneToSelf,
  WarboardStatsEntry.eWarboardStatType_HealingDoneToAllies,
  WarboardStatsEntry.eWarboardStatType_HealingDone
}
WarboardCommon.topStats[0] = {
  WarboardStatsEntry.eWarboardStatType_Kills,
  WarboardStatsEntry.eWarboardStatType_Deaths,
  WarboardStatsEntry.eWarboardStatType_Assists
}
WarboardCommon.topStats[2444859928] = {
  WarboardStatsEntry.eWarboardStatType_PlayerKills,
  WarboardStatsEntry.eWarboardStatType_Deaths,
  WarboardStatsEntry.eWarboardStatType_Assists
}
WarboardCommon.rankIndex = 1
WarboardCommon.nameIndex = 2
WarboardCommon.firstStatIndex = 3
function WarboardCommon:GetStatIndex(gamemode, stat)
  for i = 1, #self.statsShown[gamemode] do
    if self.statsShown[gamemode][i].stat == stat then
      return i
    end
  end
  return 1
end
return WarboardCommon
