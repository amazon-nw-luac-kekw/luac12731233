local UIErrors = {
  cocString = [[


@mm_loginservices_BanCodeOfConduct]],
  appealString = [[


@mm_loginservices_BanAppeal]]
}
UIErrors.errors = {}
UIErrors.errors[UIError_unknown] = {
  title = "@mm_connection_error_title",
  body = "",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_bad_request] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_badrequest",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_world_maintenence] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_worldmaintenance",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_invalid_capability] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_InvalidCapability",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_forbidden_error] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_ForbiddenError",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_invalid_ticket] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_invalidticket",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_discarded_ticket] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_discardedticket",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_bad_ticket] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_badticket",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_unable_to_connect] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_UnableToConnectError",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_no_connection] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_NoConnection",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_queue_join_failed] = {
  title = "@mm_connection_error_title",
  body = "@mm_queuejoinfailed",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_no_ticket] = {
  title = "@mm_connection_error_title",
  body = "@mm_loginservices_noticket",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_failed_to_create_character] = {
  title = "@mm_connection_error_title",
  body = "Login failed to create new character",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_character_list_failed] = {
  title = "@mm_connection_error_title",
  body = "Login character list failed",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_world_list_failed] = {
  title = "@mm_connection_error_title",
  body = "Login world list failed",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_no_worlds] = {
  title = "@mm_connection_error_title",
  body = "No active worlds are available",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_no_worlds_unknown] = {
  title = "@mm_connection_error_title",
  body = "No worlds are currently available",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_login_not_authorized] = {
  title = "@mm_connection_error_title",
  body = "Not yet authorized to begin login flow",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_duplicate_connection] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Duplicate_Connection",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_no_persistence_spawner] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_No_Persistence_Spawner",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_character_restore_failed] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Character_Restore_Failure",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_character_persist_failed] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Character_Persist_Failure",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_character_creation_failed] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Character_Service_Failure",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_character_must_rename] = {
  title = "@ui_rename_character",
  body = "@mm_rejected_Character_Must_Rename",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_aoi_character_registry_failure] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Character_Registry_Failure",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_grid_too_busy] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Grid_Too_Busy",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_no_ghost_client] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_No_Ghost_Client",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_no_spawn_points] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_No_Spawn_Points",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_aoi_server_crash] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Server_Crash",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_failed] = {
  title = "@mm_connection_error_title",
  body = "@mm_csdkerr_connection_failed",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_game_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_game_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_spawn_point_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_spawn_point_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_aoi_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_aoi_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_player_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_player_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_ingame_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_ingame_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_cannot_configure] = {
  title = "@mm_connection_error_title",
  body = "@mm_cannot_configure",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_connection_rep_registration_timeout] = {
  title = "@mm_connection_error_title",
  body = "@mm_connerr_rep_registration_timeout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_NoMessage",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_duplicate_session] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_DuplicateSession",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_character_deactivated] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_CharacterDeactivated",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_maintenence] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_Maintenance",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_abuse] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_Abuse",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_easyanticheat] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_EasyAntiCheat",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_kicked_unknown] = {
  title = "@mm_connection_error_title",
  body = "@mm_rejected_Client_Kicked_Unknown",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK
}
UIErrors.errors[UIError_banned] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_Banned",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_hacking] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedHacking",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_cheating] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedCheating",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_exploit] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedExploit",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_botting] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedBotting",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_abusive] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedAbusive",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_leaking] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedLeaking",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_disruptive] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedDisruptive",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_offensive_name] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedOffensiveName",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_offensive_companyName] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_OffensiveCompanyName",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_suspected_fraud] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_BannedSuspectedFraud",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
UIErrors.errors[UIError_banned_cs_lockout] = {
  title = "",
  body = "@mm_rejected_Client_Kicked_CSLockout",
  buttonYesText = "@ui_ok",
  buttonNoText = "",
  buttonType = ePopupButtons_OK,
  addCoc = true,
  addAppeal = true
}
return UIErrors
