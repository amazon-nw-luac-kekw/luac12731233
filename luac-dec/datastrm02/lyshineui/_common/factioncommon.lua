local FactionCommon = {}
local style = RequireScript("LyShineUI._Common.UIStyle")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
FactionCommon.factionInfoTable = {
  [eFactionType_None] = {
    factionName = "@ui_faction_none",
    factionDesc = "",
    factionSubDesc = "",
    crestBgColor = style.COLOR_WHITE,
    crestBgColorLight = style.COLOR_WHITE,
    crestBgColorDark = style.COLOR_WHITE,
    crestFgColor = style.COLOR_WHITE,
    crestBg = "lyshineui/images/icon_blank.dds",
    crestBgSmall = "lyshineui/images/icon_blank.dds",
    crestFg = "lyshineui/images/icon_blank.dds",
    crestFgSmall = "lyshineui/images/icon_blank.dds",
    crestFgSmallOutline = "lyshineui/images/icon_blank.dds",
    npcIcon = "lyshineui/images/icon_blank.dds",
    objectiveIcon = "lyshineui/images/icon_blank.dds",
    chatIcon = "lyshineui/images/icon_blank.dds",
    chatColor = style.COLOR_GRAY_60
  },
  [eFactionType_Faction1] = {
    factionName = "@ui_faction_name1",
    factionDesc = "@owg_merchant_desc",
    factionSubDesc = "@owg_merchant_sub_desc",
    factionBg = "lyShineUI/images/conversation/factions/BackgroundSyndicate.dds",
    crestBgColor = style.COLOR_FACTION_BG_1,
    crestBgColorLight = style.COLOR_FACTION_BG_LIGHT_1,
    crestBgColorDark = style.COLOR_FACTION_BG_DARK_1,
    crestFgColor = style.COLOR_FACTION_FG_1,
    crestBg = "lyshineui/images/crests/backgrounds/icon_faction_bg_1.dds",
    crestBgSmall = "lyshineui/images/crests/backgrounds/icon_faction_bg_1_small.dds",
    crestFg = "lyshineui/images/crests/foregrounds/icon_faction_fg_1.dds",
    crestFgSmall = "lyshineui/images/crests/foregrounds/icon_faction_fg_1_small.dds",
    crestFgSmallOutline = "lyshineui/images/crests/foregrounds/icon_faction_fg_1_smallOutline.dds",
    chatIcon = "lyshineui/images/crests/backgrounds/icon_faction_bg_1_small.dds",
    npcIcon = "lyshineui/images/icons/objectives/icon_faction_npc_1.dds",
    objectiveIcon = "lyshineui/images/icons/objectives/icon_Objective_Syndicate.dds",
    chatColor = style.COLOR_FACTION_CHAT_1,
    rankNames = {
      "@owg_rank_merchant_1",
      "@owg_rank_merchant_2",
      "@owg_rank_merchant_3",
      "@owg_rank_merchant_4",
      "@owg_rank_merchant_5"
    }
  },
  [eFactionType_Faction2] = {
    factionName = "@ui_faction_name2",
    factionDesc = "@owg_procurer_desc",
    factionSubDesc = "@owg_procurer_sub_desc",
    factionBg = "lyShineUI/images/conversation/factions/BackgroundMarauders.dds",
    crestBgColor = style.COLOR_FACTION_BG_2,
    crestBgColorLight = style.COLOR_FACTION_BG_LIGHT_2,
    crestBgColorDark = style.COLOR_FACTION_BG_DARK_2,
    crestFgColor = style.COLOR_FACTION_FG_2,
    crestBg = "lyshineui/images/crests/backgrounds/icon_faction_bg_2.dds",
    crestBgSmall = "lyshineui/images/crests/backgrounds/icon_faction_bg_2_small.dds",
    crestFg = "lyshineui/images/crests/foregrounds/icon_faction_fg_2.dds",
    crestFgSmall = "lyshineui/images/crests/foregrounds/icon_faction_fg_2_small.dds",
    crestFgSmallOutline = "lyshineui/images/crests/foregrounds/icon_faction_fg_2_smallOutline.dds",
    npcIcon = "lyshineui/images/icons/objectives/icon_faction_npc_2.dds",
    objectiveIcon = "lyshineui/images/icons/objectives/icon_Objective_Marauder.dds",
    chatIcon = "lyshineui/images/crests/backgrounds/icon_faction_bg_2_small.dds",
    chatColor = style.COLOR_FACTION_CHAT_2,
    rankNames = {
      "@owg_rank_procurer_1",
      "@owg_rank_procurer_2",
      "@owg_rank_procurer_3",
      "@owg_rank_procurer_4",
      "@owg_rank_procurer_5"
    }
  },
  [eFactionType_Faction3] = {
    factionName = "@ui_faction_name3",
    factionDesc = "@owg_explorer_desc",
    factionSubDesc = "@owg_explorer_sub_desc",
    factionBg = "lyShineUI/images/conversation/factions/BackgroundCovenant.dds",
    crestBgColor = style.COLOR_FACTION_BG_3,
    crestBgColorLight = style.COLOR_FACTION_BG_LIGHT_3,
    crestBgColorDark = style.COLOR_FACTION_BG_DARK_3,
    crestFgColor = style.COLOR_FACTION_FG_3,
    crestBg = "lyshineui/images/crests/backgrounds/icon_faction_bg_3.dds",
    crestBgSmall = "lyshineui/images/crests/backgrounds/icon_faction_bg_3_small.dds",
    crestFg = "lyshineui/images/crests/foregrounds/icon_faction_fg_3.dds",
    crestFgSmall = "lyshineui/images/crests/foregrounds/icon_faction_fg_3_small.dds",
    crestFgSmallOutline = "lyshineui/images/crests/foregrounds/icon_faction_fg_3_smallOutline.dds",
    npcIcon = "lyshineui/images/icons/objectives/icon_faction_npc_3.dds",
    chatIcon = "lyshineui/images/crests/backgrounds/icon_faction_bg_3_small.dds",
    chatColor = style.COLOR_FACTION_CHAT_3,
    objectiveIcon = "lyShineUI/images/icons/objectives/icon_objective_covenant.dds",
    rankNames = {
      "@owg_rank_explorer_1",
      "@owg_rank_explorer_2",
      "@owg_rank_explorer_3",
      "@owg_rank_explorer_4",
      "@owg_rank_explorer_5"
    }
  }
}
function FactionCommon:GetFaction(guildId, callback, callbackSelf)
  socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - BannerTriggers:WarBanner: GuildData request returned with no data")
      callback(callbackSelf)
      return
    end
    if guildData and guildData:IsValid() then
      local owningFaction = guildData.faction
      local owningCrest = guildData.crestData
      callback(callbackSelf, owningFaction, owningCrest)
    end
  end, function()
  end, guildId)
end
return FactionCommon
