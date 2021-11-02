local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local AudioEvents = {
  PlayMenuMusic = "Play_MX_MainMenu",
  StopMenuMusic = "Stop_MX_MainMenu",
  Set_State_MX_Main_First = "Set_State_MX_Main_First",
  Set_State_MX_Main_Return = "Set_State_MX_Main_Return",
  Set_State_FrontEnd_News = "Set_State_FrontEnd_News",
  MusicSwitch_Gameplay = "MX_Context",
  MusicSwitch_Invasion = "Music_Invasion",
  MusicSwitch_Siege = "Music_Siege",
  MusicSwitch_Darkness = "MX_Darkness",
  MusicSwitch_OutpostRush = "Music_OutpostRush",
  MusicSwitch_Duel = "Music_Duel",
  MusicSwitch_ArenaType = "MX_Arena",
  MusicSwitch_Arena = "Music_Arena",
  MusicSwitch_Housing = "Music_Housing",
  MusicState_SiegeNone = "None",
  MusicState_SiegeTimer = "Siege_Timer",
  MusicState_SiegeStarted = "Siege_Start",
  MusicState_SiegeEnded = "Siege_End",
  MusicState_Siege_Capture_Point = "Siege_CP_Captured",
  MusicState_Siege_Lose_Point = "Siege_CP_Lost",
  MusicState_Gate_Destroyed = "Siege_CP_Lost",
  MusicState_Gate_Repaired = "Siege_CP_Captured",
  MusicState_InvasionTimer = "Invasion_Timer",
  MusicState_InvasionStarted = "Invasion_Start",
  MusicState_InvasionEnded = "Invasion_End",
  MusicState_InvasionNone = "None",
  MusicState_OR_WarmUp = "OR_WarmUp",
  MusicState_OR_Start = "OR_Start",
  MusicState_OR_Conclusion_Start = "OR_Conclusion_Start",
  MusicState_OR_Conclusion_Stop = "OR_Conclusion_Stop",
  MusicState_OR_Victory = "OR_Victory",
  MusicState_OR_Defeat = "OR_Defeat",
  MusicState_OR_ScoreBoard = "OR_ScoreBoard",
  MusicState_OR_None = "None",
  Trigger_OR_BossSpawn = "Trigger_OR_BossSpawn",
  Trigger_OR_BossDeath = "Trigger_OR_BossDeath",
  FrozenScoreActivated = "",
  FrozenScoreDeactivated = "",
  MusicState_Duel_Count_3 = "Duel_Count_3",
  MusicState_Duel_Count_2 = "Duel_Count_2",
  MusicState_Duel_Count_1 = "Duel_Count_1",
  MusicState_Duel_Start = "Duel_Start",
  MusicState_Duel_Lose = "Duel_Lose",
  MusicState_Duel_Win = "Duel_Win",
  MusicState_Darkness_Major = "Major",
  MusicState_Darkness_Minor = "Minor",
  MusicState_Darkness_Completed = "Completed",
  MusicState_Darkness_Abandoned = "Abandoned",
  MusicState_Arena_Countdown = "Arena_Countdown",
  MusicState_Arena_Completed = "Arena_End",
  MusicState_Housing_Default = "Housing_Default",
  MusicState_Housing_None = "None",
  MusicState_LandClaim_Damaged = "Mx_Claim_Destroyed",
  MusicState_LandClaim_DamagedAt75 = "Mx_Claim_Destroyed",
  MusicState_LandClaim_DamagedAt50 = "Mx_Claim_Destroyed",
  MusicState_LandClaim_DamagedAt25 = "Mx_Claim_Destroyed",
  MusicState_LandClaim_Destroyed = "Mx_Claim_Destroyed",
  MusicState_LandClaim_Claimed = "Mx_Claim_Placed",
  MusicState_LandClaim_Upgraded = "Mx_Claim_Placed",
  MusicState_LandClaim_Protected = "Mx_Claim_Protection",
  MusicState_Town_Project_Started = "Mx_Claim_Placed",
  MusicState_Town_Project_Completed = "Mx_Claim_Protection",
  MusicState_Town_Project_Expired = "Mx_Claim_Destroyed",
  MusicState_Territory_Downgraded = "Mx_Claim_Destroyed",
  MusicState_LevelUp = "Mx_LevelingUp",
  MusicState_WeaponMasteryLevelUp = "Mx_LevelingUp",
  MusicState_TradeskillLevelUp = "Mx_LevelingUp",
  MusicState_RespawnScreen = "Mx_Theme_Closing",
  MusicState_Territory_LevelUp = "Mx_LevelingUp",
  MusicState_Objective_Completed = "Mx_Claim_Placed",
  UIState_Default = "Default",
  UIState_Inventory = "Inventory",
  UIState_Crafting = "Crafting",
  UIState_LoadingScreen = "Loading",
  UIState_Scoreboard = "Scoreboard",
  UIState_QuestScreen = "Quests",
  UIState_RespawnScreen = "Respawn",
  onKill_XPnumber = "Play_UI_Kill_XP_Gain",
  Meter_FullHealth = "Play_HUD_FullHealth",
  Meter_EnterHealthWarning = "",
  Meter_ExitHealthWarning = "",
  Meter_EnterHealthCritical = "",
  Meter_ExitHealthCritical = "",
  Meter_FullStamina = "Play_HUD_Full_Stamina",
  Meter_EnterStaminaWarning = "",
  Meter_ExitStaminaWarning = "",
  Meter_EnterStaminaCritical = "",
  Meter_ExitStaminaCritical = "",
  Meter_StaminaLocked = "",
  Meter_StaminaUnlocked = "",
  Meter_FullMana = "Play_HUD_Full_Mana",
  Meter_EnterManaWarning = "",
  Meter_ExitManaWarning = "",
  Meter_EnterManaCritical = "",
  Meter_ExitManaCritical = "",
  Meter_ManaLocked = "",
  Meter_ManaUnlocked = "",
  Meter_Full_Q = "Play_HUD_Full_Q_meter",
  Meter_Full_R = "Play_HUD_Full_R_meter",
  Meter_Full_F = "Play_HUD_Full_F_meter",
  Ability_On_Cooldown = "Play_HUD_Ability_On_Cooldown",
  Killed_Player = "Play_UI_Killed_Player",
  KnockedDown_Player = "Play_UI_KnockedDown_Player",
  Accept = "Play_UI_Accept",
  Cancel = "Play_UI_08",
  Play = "Play_UI_21",
  OnShow = "",
  OnHide = "",
  OnClick = "Play_UI_00",
  OnRClick = "Play_UI_05",
  OnEmoteButtonPress = "Play_UI_EmotesPopup_OnClick",
  OnHover = "Play_UI_Hover",
  OnHover_ButtonSimpleText = "Play_UI_Hover_ButtonSimpleText",
  OnHover_CharacterCreation = "Play_UI_Hover_CharacterCreation",
  OnHover_Dropdown = "Play_UI_Hover_Dropdown",
  OnHover_DropdownListItem = "Play_UI_Hover_DropdownListItem",
  OnHover_EmoteMenu = "Play_UI_EmotesPopup_OnHover",
  OnHover_EscapeMenu = "Play_UI_Hover_EscapeMenu",
  OnHover_Feedback = "Play_UI_Hover_Feedback",
  OnHover_LandingScreen = "Play_UI_Hover_LandingScreen",
  OnHover_LegalScreen = "Play_UI_Hover_LegalScreen",
  OnHover_MarkersLayer = "Play_UI_Hover_Map_MarkersLayer",
  OnHover_OptionsListItem = "Play_UI_Hover_OptionsListItem",
  OnHover_ToggleButton = "Play_UI_Hover_ToggleButton",
  Tooltip_Show = "Play_UI_Tooltip_Show",
  MapFlyout_OnShow = "UI_Hover_CharacterCreation",
  MapFlyout_OnHide = "UI_Hover_ButtonSimpleText",
  MapZoomIn = "Play_UI_Map_Zoom_In",
  MapZoomOut = "Play_UI_Map_Zoom_Out",
  MapIconOnHover = "Play_UI_Crafting_Item_Hover",
  MapIconOnHoverSettlement = "Play_UI_Map_Hover_Settlement",
  MapIconOnHoverFort = "Play_UI_Map_Hover_Fort",
  MapIconOnHoverTerritory = "Play_UI_Map_Hover_Territory",
  MapWayPointSet = "Play_UI_Map_Place_WayPoint",
  PlayMapOpen = "Play_UI_MapShow",
  PlayMapClose = "Play_UI_MapHide",
  OnHover_ItemDraggable = "Play_UI_Hover_ItemDraggable",
  OnItemStackSplit = "Play_UI_Inventory_SplitStack",
  OnTakeAllPressed = "Play_UI_Inventory_PickUp_Dropped_Item",
  OnItemDamaged = "Play_UI_ItemDamaged",
  OnGatherWithoutTool = "Play_UI_Interact_Fail",
  InventorySelect = "Play_UI_Interact_Option",
  BoxOpeningItem_Rarity0 = "Play_UI_Crafting_Intro",
  BoxOpeningItem_Rarity1 = "Play_UI_Crafting_Inventory_Add",
  BoxOpeningItem_Rarity2 = "Play_UI_Crafting_Rarity_2",
  BoxOpeningItem_Rarity3 = "Play_UI_Crafting_Rarity_3",
  BoxOpeningItem_Rarity4 = "Play_UI_Crafting_Rarity_3",
  OnQuickBarPress = "Play_UI_QuickBarSelect",
  OnQuickBarPressEmpty = "Play_UI_QuickBarSelectEmpty",
  OnFocusStart = "Play_UI_Slider_OnFocus_Start",
  OnFocusStop = "Play_UI_Slider_OnFocus_Stop",
  Failure = "Play_UI_34",
  InteractOptionPressed = "Play_UI_Interact_Option",
  InteractOptionHold_Loop_Play = "Play_UI_On_interact_Hold_On",
  InteractOptionHold_Loop_Stop = "Stop_UI_On_interact_Hold_Off",
  OnSliderChanged = "Play_UI_Slider_OnTick",
  OnText = "Play_UI_14",
  FrontEnd_OnCreateCharacterBeginPress = "Play_UI_FrontEnd_CreateCharacter_Begin",
  FrontEnd_OnCreateCharacterHover = "Play_UI_FrontEnd_CreateCharacterHover",
  FrontEnd_OnCreateCharacterPress = "Play_UI_FrontEnd_CreateCharacter",
  FrontEnd_OnSelectCharacterHover = "Play_UI_FrontEnd_Tab_Hover",
  FrontEnd_OnSelectCharacterPress = "Play_UI_FrontEnd_SelectCharacter",
  FrontEnd_OnDeleteCharacterHover = "Play_UI_FrontEnd_Tab_Hover",
  FrontEnd_OnDeleteCharacterPress = "Play_UI_FrontEnd_DeleteCharacter",
  FrontEnd_OnServerSelectHover = "Play_UI_FrontEnd_Tab_Hover",
  FrontEnd_OnServerSelectPress = "Play_UI_FrontEnd_SeverSelect",
  FrontEnd_OnPlayHover = "Play_UI_FrontEnd_Tab_Hover",
  FrontEnd_OnPlayPress = "Play_UI_FrontEnd_PressPlay",
  FrontEnd_OnAppearenceHover = "Play_UI_FrontEnd_AppearanceHover",
  FrontEnd_OnAppearencePress = "Play_UI_FrontEnd_AppearanceSelect",
  FrontEnd_OnAppearenceGridHover = "Play_UI_FrontEnd_Tab_Hover",
  FrontEnd_OnAppearenceGridPress = "Play_UI_FrontEnd_AppearanceGrid",
  FrontEnd_OnRandomizeHover = "Play_UI_FrontEnd_Hover",
  FrontEnd_OnRandomizePress = "Play_UI_FrontEnd_Randomize",
  FrontEnd_OnBackHover = "Play_UI_FrontEnd_Hover",
  FrontEnd_OnBackPress = "Play_UI_FrontEnd_Back",
  FrontEnd_OnNextHover = "Play_UI_FrontEnd_Hover",
  FrontEnd_OnNextPress = "Play_UI_FrontEnd_Next",
  FrontEnd_OnCrestForgroundHover = "Play_UI_FrontEnd_Crest_Hover",
  FrontEnd_OnCrestForgroundPress = "Play_UI_Crest_SelectForeground",
  FrontEnd_OnCrestForgroundColorHover = "Play_UI_FrontEnd_HoverSmall",
  FrontEnd_OnCrestForgroundColorPress = "Play_UI_Crest_SelectFGColor",
  FrontEnd_OnCrestBackgroundHover = "Play_UI_FrontEnd_Crest_Hover",
  FrontEnd_OnCrestBackgroundPress = "Play_UI_Crest_SelectBackground",
  FrontEnd_OnCrestBackgroundColorHover = "Play_UI_FrontEnd_HoverSmall",
  FrontEnd_OnCrestBackgroundColorPress = "Play_UI_Crest_SelectBGColor",
  FrontEnd_OnRefreshServerPress = "",
  FrontEnd_Continue = "Play_UI_FrontEnd_Continue",
  Banner_LevelUp = "Play_UI_Banner_LevelUp",
  Banner_WeaponMasteryLevelUp = "Play_UI_Banner_LevelUp",
  Banner_TradeskillLevelUp = "Play_UI_Banner_LevelUp",
  Banner_WarDeclared = "Play_UI_Banner_Declare_War",
  Banner_WarPhase_War = "Play_UI_Banner_Declare_War",
  Banner_WarPhase_Conquest = "Play_UI_Banner_Declare_War",
  Banner_WarPhase_WarResolution = "Play_UI_Banner_Declare_War",
  Banner_WarExtended = "Play_UI_Banner_Extend_War",
  Banner_WarStarted = "Play_UI_Banner_Start_War",
  Banner_WarEnded = "Play_UI_Banner_End_War",
  Banner_Achievement = "Play_UI_Banner_Achievement",
  Banner_DarknessStarted = "Play_UI_Banner_Achievement",
  Banner_DarknessCompleted = "Play_UI_Banner_Achievement",
  Banner_TownProjectStart = "Play_UI_Banner_Achievement",
  Banner_TownProjectExpire = "Play_UI_Banner_End_War",
  Banner_TownProjectComplete = "Play_UI_Banner_Achievement",
  Banner_TerritoryDowngrade = "Play_UI_Banner_End_War",
  Banner_Territory_LevelUp = "Play_UI_Banner_LevelUp",
  Compass_Open = "Play_UI_Banner_Achievement",
  Compass_Close = "Play_UI_Inventory_Outro",
  OnBuildModeAvailable = "Play_UI_02",
  OnBuildModeOpen = "Play_UI_Build_Intro",
  OnBuildModeClose = "Play_UI_Build_Outro",
  OnBuildModeScrollCategory = "Play_UI_Build_Scroll_Catagory",
  OnBuildModeScrollTier = "Play_UI_Build_Scroll_Tier",
  OnCampBroken = "Play_UI_26",
  OnCampDestroyHold = "Play_UI_38",
  OnPvpFlag_Pending = "Play_UI_PvP_Flag_Pending",
  OnPvpFlag_On = "Play_UI_PvP_Flag_On",
  OnPvpFlag_Off = "Play_UI_PvP_Flag_Off",
  OnPvpFlag_Timer = "Play_UI_PvP_Flag_Timer",
  OnEncumberedBackpack = "Play_UI_Encumbered_Backpack",
  OnUnencumberedBackpack = "Play_UI_Unencumbered_Backpack",
  OnEncumberedEquipment = "Play_UI_Encumbered_Equipment",
  OnUnencumberedEquipment = "Play_UI_Unencumbered_Equipment",
  Screen_InventoryOpen = "Play_UI_Inventory_Intro",
  Screen_InventoryClose = "Play_UI_Inventory_Outro",
  Screen_EscapeMenuOpen = "Play_UI_Esc_Open",
  Screen_EscapeMenuClose = "Play_UI_Esc_Close",
  Screen_SkillsOpen = "Play_UI_Skills_Intro",
  Screen_SkillsClose = "Play_UI_Skills_Outro",
  Screen_TerritoryClaimSelect = "Play_UI_Territory_Claim_Select",
  Screen_TerritoryClaimOpen = "Play_UI_Territory_Claim_Intro",
  Screen_TerritoryClaimClose = "Play_UI_Territory_Claim_Outro",
  Screen_ManageSettlementOpen = "Play_UI_Settlement_Manage_Intro",
  Screen_ManageSettlementClose = "Play_UI_Settlement_Manage_Outro",
  Screen_RespawnOpen = "Play_UI_Respawn_Transition",
  Screen_WarDeclarationConfirm = "Play_UI_Banner_LevelUp",
  Screen_SiegeWindowSet = "Play_UI_OnSiegeWindowSet",
  Screen_TerritoryStandingOpen = "Play_UI_Crafting_Intro",
  Screen_TerritoryStandingClose = "Play_UI_Crafting_Outro",
  Screen_TerritoryStandingHover = "Play_UI_Crafting_Material_Hover",
  Screen_TerritoryStandingHSelect = "Play_UI_FrontEnd_PressPlay",
  LandClaim_Damaged = "Play_UI_38",
  LandClaim_DamagedAt75 = "Play_UI_38",
  LandClaim_DamagedAt50 = "Play_UI_38",
  LandClaim_DamagedAt25 = "Play_UI_38",
  LandClaim_Destroyed = "Play_UI_38",
  LandClaim_Claimed = "Play_UI_02",
  LandClaim_Upgraded = "Play_UI_02",
  LandClaim_Protected = "Play_UI_02",
  Crafting_Intro = "Play_UI_Crafting_Intro",
  Crafting_IntroStep2 = "Play_UI_Crafting_Intro_Step_2",
  Crafting_Outro = "Play_UI_Crafting_Outro",
  Crafting_Tab_Hover = "Play_UI_Crafting_Tab_Hover",
  Crafting_Tab_Select = "Play_UI_Crafting_Tab_Select",
  Crafting_Item_Hover = "Play_UI_Crafting_Item_Hover",
  Crafting_Item_Select = "Play_UI_Crafting_Item_Select",
  Crafting_Panel_Intro = "Play_UI_Crafting_Panel_Intro",
  Crafting_Panel_Outro = "Play_UI_Crafting_Panel_Outro",
  Crafting_Material_Hover = "Play_UI_Crafting_Material_Hover",
  Crafting_Material_Select = "Play_UI_Crafting_Material_Select",
  Crafting_Button_Hover = "Play_UI_Crafting_Hover",
  Crafting_Button_Select = "Play_UI_Crafting_Select",
  Crafting_ProgressBar_Loop_Play = "Play_UI_Crafting_ProgressBar_Lp",
  Crafting_ProgressBar_Loop_Stop = "Stop_UI_Crafting_ProgressBar_Lp",
  Crafting_Done = "Play_UI_Crafting_Complete",
  Crafting_Inventory_Add = "Play_UI_Crafting_Inventory_Add",
  Crafting_Increment = "Play_UI_Crafting_Increment",
  Crafting_Rarity_0 = "Play_UI_Crafting_Rarity_0",
  Crafting_Rarity_1 = "Play_UI_Crafting_Rarity_1",
  Crafting_Rarity_2 = "Play_UI_Crafting_Rarity_2",
  Crafting_Rarity_3 = "Play_UI_Crafting_Rarity_3",
  Crafting_Perk_Show = "Play_UI_Crafting_Perk_Show",
  Crafting_GemSlot_Show = "Play_UI_Crafting_GemSlot_Show",
  Progression_TabSelected = "Play_UI_Guild_Upper_Tab_Selected",
  AttributesConfirmed = "Play_UI_Banner_LevelUp",
  WeaponMastery_WeaponHover = "Play_UI_Hover",
  WeaponMastery_WeaponClick = "Play_UI_Accept",
  WeaponMastery_TreeAbilityHover = "Play_UI_Hover",
  WeaponMastery_TreeAbilitySelected = "Play_UI_Accept",
  WeaponMastery_TreeAbilityDeselected = "Play_UI_08",
  WeaponMastery_TreeAbilitiesCommitted = "Play_UI_Banner_LevelUp",
  P2P_TradeLockIn = "Play_UI_Banner_LevelUp",
  P2P_Tick = "Play_UI_Hover_ItemDraggable",
  OnTradeSkillHover = "Play_UI_Hover",
  OnTradeSkillPress = "Play_UI_Progression_TradeSkill_Sel",
  AbilitySlotHovered = "Play_UI_Hover",
  AbilitySlotClicked = "Play_UI_Accept",
  AbilityOptionHovered = "Play_UI_Hover",
  AbilityAssigned = "Play_UI_FrontEnd_PressPlay",
  OnRespawn = "Play_UI_Respawn_Select",
  Guild_OwnershipChanged = "Play_UI_Banner_Achievement",
  OnInvitedToGuild = "Play_UI_Guild_InviteToGuild",
  OnGuildPromote = "Play_UI_Guild_OnGuildPromote",
  Guild_TabSelected = "Play_UI_Guild_Upper_Tab_Selected",
  Guild_UpperTabSelected = "Play_UI_Guild_Tab_Selected",
  Guild_MyTabSelected = "Play_UI_Guild_My_Tab_Selected",
  Guild_PermissionSelect = "Play_UI_Guild_Permission_Select",
  OnGuildNotificationAccept = "Play_UI_Accept",
  OnGuildNotificationDecline = "Play_UI_08",
  Contacts_Open = "Play_UI_Contacts_Open",
  Contacts_Close = "Play_UI_Contacts_Close",
  Contacts_Invite_Open = "Play_UI_Contacts_Invite_Open",
  Contacts_Invite_Send = "Play_UI_Contacts_Invite_Send",
  Contacts_Invite_Cancel = "Play_UI_Contacts_Invite_Cancel",
  Contacts_Unfriend = "Play_UI_Contacts_Unfriend",
  Contacts_Invite_Accept = "Play_UI_Contacts_Invite_Accept",
  Contacts_Invite_Reject = "Play_UI_Contacts_Invite_Reject",
  Roster_MyGuildTabSelected = "Play_UI_Roster_MyGuild_Tab_Selected",
  Roster_Tab_Selected = "Play_UI_Roster_Tab_Selected",
  Roster_ShowInviteForm = "Play_UI_Roster_ShowInviteForm",
  Roster_OnInviteSubmit = "Play_UI_Roster_OnInvite_Submit",
  Roster_OnInviteCancel = "Play_UI_Roster_OnInvite_Cancel",
  Invites_Added = "Play_UI_Invite_Added",
  Invites_TabSelected = "Play_UI_Invite_Tab_Selected",
  Invites_Accept = "Play_UI_Invite_Accept",
  Invites_Reject = "Play_UI_Invite_Reject",
  Crest_Submit = "Play_UI_Crest_Submit",
  Crest_Revert = "Play_UI_Crest_Revert",
  Crest_SelectForeground = "Play_UI_Crest_SelectForeground",
  Crest_SelectBackground = "Play_UI_Crest_SelectBackground",
  Crest_SelectFGColor = "Play_UI_Crest_SelectFGColor",
  Crest_SelectBGColor = "Play_UI_Crest_SelectBGColor",
  Treasury_Withdrawal = "Play_UI_Use_Coin",
  Treasury_Deposit = "Play_UI_Use_Coin",
  Treasury_SetDailyLimit = "Play_UI_Use_Coin",
  GroupSelfLeft = "Play_UI_Groups_Self_Left",
  GroupOtherLeft = "Play_UI_Groups_Other_Left",
  GroupInviteSent = "Play_UI_Group_Invite_Sent",
  GroupOnIconHover = "Play_UI_Hover",
  OnInvitedToGroup = "Play_UI_Invite",
  OnSelectMale = "SetSwitch_Gender_Male",
  OnSelectFemale = "SetSwitch_Gender_Female",
  OnRotationStart = "Play_UI_Character_Rotate",
  OnRotationEnd = "Stop_UI_Character_Rotate",
  InitialToastShow = "Play_UI_FTUE_Tutorial_IntialOpen_01",
  FollowUpToastShow = "Play_UI_FTUE_Tutorial_Open_01",
  WhisperSounds = "Play_UI_FTUE_Prompts",
  FTUEPromptComplete = "Play_UI_Crafting_Inventory_Add",
  OnWhisperReceived = "Play_UI_Whisper_Received",
  OnWhisperSent = "Play_UI_Whisper_Sent",
  Emote_Popup_Show = "Play_UI_EmotesPopup_Show",
  Emote_Popup_Hide = "Play_UI_EmotesPopup_Hide",
  Contracts_Sell = "Play_UI_Use_Coin",
  Contracts_Tab_Select = "Play_UI_Roster_MyGuild_Tab_Selected",
  Contracts_Popup_Show = "Play_UI_Crafting_Panel_Intro",
  Contracts_Popup_Hide = "Play_UI_Crafting_Panel_Outro",
  Contracts_Category_Tab_Select = "Play_UI_Roster_MyGuild_Tab_Selected",
  Contracts_ListItem_Select = "Play_UI_Roster_Tab_Selected",
  Objectives_AddedPinnedObjective = "Play_UI_Accept",
  Objectives_CompletedPinnedObjective = "Play_UI_Crafting_Complete",
  Objectives_UpdatedPinnedTask = "Play_UI_Hover",
  Objectives_CompletedPinnedTask = "Play_UI_Guild_OnGuildPromote",
  Objectives_CompletedPinnedIngredient = "Play_UI_Guild_OnGuildPromote",
  Objectives_Completed = "Play_UI_02",
  OWG_OpenDetails = "Play_UI_Accept",
  OWG_Mission_OnHover = "Play_UI_Hover_ButtonSimpleText",
  OWG_GuildShopLevel_OnHover = "Play_UI_Hover_ButtonSimpleText",
  OWG_GuildShopLevel_Level_Select = "Play_UI_Accept",
  Lore_JournalOpen = "Play_UI_Lore_JournalOpen",
  Lore_JournalClose = "Play_UI_Lore_JournalClose",
  Lore_ChangeViewIn = "Play_UI_Lore_ChangeViewIn",
  Lore_ChangeViewOut = "Play_UI_Lore_ChangeViewOut",
  Lore_RefreshView = "Play_UI_Lore_RefreshView",
  Lore_ChangePage = "Play_UI_Lore_ChangePage",
  Lore_ClickTextLink = "Play_UI_Lore_ClickTextLink",
  Lore_HoverTopic = "Play_UI_Lore_HoverTopic",
  Lore_HoverChapter = "Play_UI_Lore_HoverChapter",
  Lore_GrandOpening = "Play_UI_Lore_GrandOpening",
  Ping_Drop = "Play_UI_Ping_Drop",
  Ping_ShoutDrop = "Play_UI_Ping_ShoutDrop",
  Ping_ShoutWheelHold = "Play_UI_Ping_ShoutWheelHold",
  Ping_TargetDrop = "Play_UI_Ping_Target",
  Ping_Wheel_Open = "Play_UI_PingWheel_Open",
  Ping_Wheel_Close = "Play_UI_PingWheel_Close",
  Ping_Wheel_OnHover = "Play_UI_PingWheel_OnHover",
  Ping_Wheel_Action = "Play_UI_PingWheel_Action",
  Tradeskill_LevelUp = "Play_Tradeskill_LevelUp",
  LootTickerItems_OnReceived = "Play_UI_LootTicker_Item",
  Beep1_2D = "Play_Beep1_2D",
  Beep2_2D = "Play_Beep2_2D",
  Beep3_2D = "Play_Beep3_2D",
  Beep4_2D = "Play_Beep4_2D",
  Beep5_2D = "Play_Beep5_2D",
  Raid_Popup_Show = "Play_UI_Crafting_Panel_Intro",
  Raid_Popup_Hide = "Play_UI_Crafting_Panel_Outro",
  Conversation_Screen_Open = "Play_UI_Conversation_Open",
  Conversation_Screen_Close = "Play_UI_Conversation_Close",
  AcceptObjective = "Play_UI_AcceptObjective",
  CompleteObjective = "Play_UI_CompleteObjective",
  ObjectiveDetails = "Play_UI_ObjectiveDetails",
  RefreshConversation = "Play_UI_RefreshConversation",
  Mission_Reward = "Play_UI_Mission_Reward",
  PinnedObjective = "Play_UI_PinnedObjective",
  ChooseFaction = "Play_UI_ChooseFaction",
  War_PointTaken_Attackers = "Play_HUD_War_PointTaken_Attackers",
  War_PointTaken_Defenders = "Play_HUD_War_PointTaken_Defenders",
  War_GateBreached_Attackers = "Play_HUD_War_GateBreached_Attackers",
  War_GateBreached_Defenders = "Play_HUD_War_GateBreached_Defenders",
  MetaAchievements_List_Expand = "Play_UI_08",
  MetaAchievements_List_Collapse = "Play_UI_03",
  MetaAchievements_List_Hover = "Play_UI_FrontEnd_Tab_Hover",
  MetaAchievements_List_Category_Select = "Play_UI_Lore_JournalOpen",
  MetaAchievements_Unlock = "Play_UI_Banner_Achievement",
  MetaAchievements_Partial_Milestone = "Play_UI_Banner_Achievement",
  Ingame_Server_Warning_Message = "Play_UI_34",
  entityId = EntityId()
}
function AudioEvents:PlaySound(name)
  if name ~= nil then
    AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger(name, true, self.entityId)
  end
end
function AudioEvents:PlaySoundPositional(entityId, name)
  if entityId and entityId:IsValid() and name ~= nil then
    local viewportPosition = UiTransformBus.Event.GetViewportPosition(entityId)
    local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
    local viewportCenterX = viewportSize.x / 2
    local viewportCenterY = viewportSize.y / 2
    local normalizedX = (viewportPosition.x - windowCenterX) / windowCenterX
    local normalizedY = (windowCenterY - viewportPosition.y) / windowCenterY
  end
end
function AudioEvents:SwitchMusicDB(switch, state)
  if not self.playerEntityId then
    self.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if self.playerEntityId ~= nil then
      DynamicBus.switchMusicBus.Event.SwitchMusicDB(self.playerEntityId, switch, state)
    end
  else
    DynamicBus.switchMusicBus.Event.SwitchMusicDB(self.playerEntityId, switch, state)
  end
end
function AudioEvents:onMixStateChanged(mixState)
  if not self.playerEntityId then
    self.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if self.playerEntityId == nil then
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Mix_state", mixState)
    else
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.playerEntityId, mixState)
    end
  else
    DynamicBus.mixStateBus.Event.onMixStateChanged(self.playerEntityId, mixState)
  end
end
function AudioEvents:onUIStateChanged(UIstate)
  if not self.playerEntityId then
    self.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if self.playerEntityId == nil then
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("UI_state", UIstate)
    else
      DynamicBus.uiStateBus.Event.onUIStateChanged(self.playerEntityId, UIstate)
    end
  else
    DynamicBus.uiStateBus.Event.onUIStateChanged(self.playerEntityId, UIstate)
  end
end
function AudioEvents:onOutputConfigurationChanged(config)
  if self.playerEntityId ~= nil then
    if config == eAudioSetupType_Headphones then
      DynamicBus.outputConfigBus.Event.onOutputConfigurationChanged(self.playerEntityId, config)
    else
      DynamicBus.outputConfigBus.Event.onOutputConfigurationChanged(self.playerEntityId, config)
    end
  else
    self.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if config == eAudioSetupType_Headphones then
      DynamicBus.outputConfigBus.Event.onOutputConfigurationChanged(self.playerEntityId, config)
    else
      DynamicBus.outputConfigBus.Event.onOutputConfigurationChanged(self.playerEntityId, config)
    end
  end
end
function AudioEvents:QueueSound(eventName, soundToPlay, throttleTime)
  if not self.throttledSounds then
    self.throttledSounds = {}
  end
  local throttledSound = self.throttledSounds[eventName]
  if not throttledSound then
    self:PlaySound(soundToPlay)
    throttledSound = {time = throttleTime}
    self.throttledSounds[eventName] = throttledSound
  end
  self:SetTicking(true)
end
function AudioEvents:OnTick(deltaTime)
  local numQueued = 0
  for eventName, throttledSound in pairs(self.throttledSounds) do
    throttledSound.time = throttledSound.time - deltaTime
    if 0 >= throttledSound.time then
      self.throttledSounds[eventName] = nil
    else
      numQueued = numQueued + 1
    end
  end
  if numQueued == 0 then
    self:SetTicking(false)
  end
end
function AudioEvents:SetTicking(shouldTick)
  self.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if shouldTick then
    if not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.playerEntityId, self)
    end
  elseif self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.playerEntityId, self)
    self.tickBusHandler = nil
  end
end
return AudioEvents
