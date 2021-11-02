local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local Options = {
  Properties = {
    MenuHolder = {
      default = EntityId()
    },
    TabbedListHeader = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    ScreenHeader = {
      default = EntityId()
    },
    KeybindSections = {
      default = {
        EntityId(),
        EntityId(),
        EntityId()
      }
    },
    KeybindResetButton = {
      default = EntityId()
    },
    GameplayResetButton = {
      default = EntityId()
    },
    AudioResetButton = {
      default = EntityId()
    },
    CommunicationsResetButton = {
      default = EntityId()
    },
    SocialResetButton = {
      default = EntityId()
    },
    VisualsResetButton = {
      default = EntityId()
    },
    TwitchResetButton = {
      default = EntityId()
    },
    AccessibilityResetButton = {
      default = EntityId()
    },
    PreferencesResetButton = {
      default = EntityId()
    },
    ClickThroughCover = {
      default = EntityId()
    },
    KeyBindingScreen = {
      default = EntityId()
    },
    GameplayScreen = {
      default = EntityId()
    },
    GameplayScreenContent = {
      default = EntityId()
    },
    VisualScreen = {
      default = EntityId()
    },
    VisualScreenContent = {
      default = EntityId()
    },
    PreferencesScreen = {
      default = EntityId()
    },
    PreferencesScreenContent = {
      default = EntityId()
    },
    AudioScreen = {
      default = EntityId()
    },
    AudioScreenContent = {
      default = EntityId()
    },
    CommsScreen = {
      default = EntityId()
    },
    CommsScreenContent = {
      default = EntityId()
    },
    SocialScreen = {
      default = EntityId()
    },
    SocialScreenContent = {
      default = EntityId()
    },
    TwitchScreen = {
      default = EntityId()
    },
    TwitchScreenContent = {
      default = EntityId()
    },
    AccessibilityScreen = {
      default = EntityId()
    },
    AccessibilityScreenContent = {
      default = EntityId()
    },
    AboutScreen = {
      default = EntityId()
    },
    ScrollWheelHelpers = {
      default = {
        EntityId()
      }
    },
    KeyBindingScreenScrollableContent = {
      default = EntityId()
    },
    KeyBindingScreenScrollMouseHelper = {
      default = EntityId()
    }
  },
  INPUT_TYPE_DROPDOWN = "Dropdown",
  INPUT_TYPE_TEXT = "Text",
  INPUT_TYPE_TOGGLE = "Toggle",
  INPUT_TYPE_SLIDER = "Slider",
  INPUT_TYPE_EXTERNAL_LINK = "ExternalLink",
  DISPLAY_MODE_FULLSCREEN = 0,
  DISPLAY_MODE_WINDOWED = 1,
  DISPLAY_MODE_WINDOWED_FULLSCREEN = 2,
  mResolutionDropdown = nil,
  mLastResolution = nil,
  mLastResolutionData = nil,
  mIsPopupEnabled = nil,
  mPopupTimeDisplayed = 0,
  mPopupRevertTime = 10,
  mPopupEventId = "Resolution_Confirm_Popup",
  mPopupKeyAlreadyBoundId = "Popup_KeyAlreadyBound",
  mPopupResetKeyBindingsId = "Popup_ResetKeyBindings",
  mPopupResetResetGameplaySettingsId = "Popup_ResetGameplaySettings",
  mPopupResetAudioSettingsId = "Popup_ResetAudioSettings",
  mPopupResetCommunicationSettingsId = "Popup_ResetCommunicationSettings",
  mPopupResetSocialSettingsId = "Popup_ResetSocialSettings",
  mPopupResetVisualSettingsId = "Popup_ResetVisualSettings",
  mPopupResetPreferencesSettingsId = "Popup_ResetPreferencesSettings",
  mPopupResetTwitchSettingsId = "Popup_ResetTwitchSettings",
  mPopupResetAccessibilitySettingsId = "Popup_ResetAccessibilitySettings",
  DATA_LAYER_OPTIONS = "Hud.LocalPlayer.Options",
  mModeSetPath = "Hud.LocalPlayer.Voip.OnModeSet",
  mOptionsDataNode = nil,
  mKeyBindingScreenListItems = {},
  mGameplayScreenListItems = {},
  mVisualScreenListItems = {},
  mPreferencesScreenListItems = {},
  mAudioScreenListItems = {},
  mCommsScreenListItems = {},
  mSocialScreenListItems = {},
  mTwitchScreenListItems = {},
  mAccessibilityScreenListItems = {},
  mAboutScreenListItems = {},
  mCurrentSelectedScreen = nil,
  mCurrentSelectedScreenListItems = nil,
  mCurrentSelectedListItem = nil,
  mKeyBindTitleHeight = 43,
  mKeyBindListHeight1 = 0,
  mKeyBindListHeight2 = 0,
  mKeyBindListHeight3 = 0,
  mInputTypeWidth = 380,
  scrollHelperStepValues = {},
  optionEntities = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Options)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Options)
local ResolutionManager = RequireScript("LyShineUI.Options.ResolutionManager")
local TutorialCommon = RequireScript("LyShineUI._Common.TutorialCommon")
function Options:OnInit()
  BaseScreen.OnInit(self)
  self.optionsHandler = DynamicBus.Options.Connect(self.entityId, self)
  self.MenuButtonData = {
    {
      screen = self.KeyBindingScreen,
      text = "@ui_options_keybindings",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.PreferencesScreen,
      text = "@ui_options_preferences",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.GameplayScreen,
      text = "@ui_options_gameplay",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.VisualScreen,
      text = "@ui_options_visuals",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.AudioScreen,
      text = "@ui_options_audio",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.CommsScreen,
      text = "@ui_options_comms",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.SocialScreen,
      text = "@ui_options_social",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.TwitchScreen,
      text = "@ui_options_twitch",
      callback = self.SetSelectedScreenVisible,
      featureFlag = "UIFeatures.g_enableTwitchSystem"
    },
    {
      screen = self.AccessibilityScreen,
      text = "@ui_options_accessibility",
      callback = self.SetSelectedScreenVisible,
      featureFlag = "UIFeatures.g_uiEnableAccessibilitySettings"
    },
    {
      screen = self.AboutScreen,
      text = "@ui_options_about",
      callback = self.SetSelectedScreenVisible
    }
  }
  self.TabbedListHeaderData = {
    {
      screen = self.KeyBindingScreen,
      text = "@ui_options_settings",
      callback = nil,
      width = 338,
      height = 70,
      glowOffsetWidth = 222
    }
  }
  self.GameplayListItemData = {
    {
      text = "@ui_invertcamera",
      desc = "@ui_invertlook_desc",
      dataNode = "Controls.InvertLook",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableInvertLook",
      callback2 = "EnableInvertLook",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_looksensitivity",
      desc = "@ui_looksensitivity_desc",
      dataNode = "Controls.CameraSensitivity",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetCameraSensitivity",
      minValue = 10,
      displayToGameFunc = function(percentage)
        return percentage * percentage * 1.0E-4
      end,
      gameToDisplayFunc = function(percentage)
        return math.sqrt(percentage) * 100
      end
    },
    {
      text = "@ui_cameraShake",
      desc = "@ui_cameraShake_desc",
      dataNode = "Controls.CameraShake",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraShake",
      callback2 = "EnableCameraShake",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_strafeCamera",
      desc = "@ui_strafeCamera_desc",
      dataNode = "Controls.StrafeCamera",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableStrafeCamera",
      callback2 = "EnableStrafeCamera",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_uiStrafeCameraSettings"
    },
    {
      text = "@ui_alwaysShowReticle",
      desc = "@ui_alwaysShowReticle_desc",
      dataNode = "Controls.AlwaysShowReticle",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAlwaysShowReticle",
      callback2 = "EnableAlwaysShowReticle",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_uiEnableReticleAlwaysShowing"
    },
    {
      text = "@ui_showInspectHint",
      desc = "@ui_showInspectHint_desc",
      dataNode = "Controls.ShowInspectHint",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableShowInspectHint",
      callback2 = "EnableShowInspectHint",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.social.enable-player-inspect"
    },
    {
      text = "@ui_enable_hudShowVitalsValues",
      desc = "@ui_enable_hudShowVitalsValues_decstription",
      dataNode = "Video.HudShowVitalsValues",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableHudShowVitalsValues",
      callback2 = "EnableHudShowVitalsValues",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_hudAlwaysFade",
      desc = "@ui_enable_hudAlwaysFade_description",
      dataNode = "Video.HudAlwaysFade",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableHudAlwaysFade",
      callback2 = "EnableHudAlwaysFade",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_hudShowAllWeapons",
      desc = "@ui_enable_hudShowAllWeapons_description",
      dataNode = "Video.HudShowAllWeapons",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableHudShowAllWeapons",
      callback2 = "EnableHudShowAllWeapons",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_hudShowAbilityRadials",
      desc = "@ui_enable_hudShowAbilityRadials_description",
      dataNode = "Video.HudShowAbilityRadials",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableHudShowAbilityRadials",
      callback2 = "EnableHudShowAbilityRadials",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_newDamageNumbers",
      desc = "@ui_enable_newDamageNumbers_description",
      dataNode = "Video.UseNewDamageNumbers",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableUseNewDamageNumbers",
      callback2 = "EnableUseNewDamageNumbers",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_accept_duel_invites",
      desc = "@ui_accept_duel_invites_description",
      dataNode = "GenericInvite.DuelEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableDuelInvites",
      callback2 = "EnableDuelInvites",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-game-mode-duels"
    },
    {
      text = "@ui_auto_traverse",
      desc = "@ui_auto_traverse_description",
      dataNode = "Controls.AutoTraverse",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoTraverse",
      callback2 = "EnableAutoTraverse",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock",
      desc = "@ui_enable_camera_lock_description",
      dataNode = "Controls.CameraLock",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLock",
      callback2 = "EnableCameraLock",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock_target_follow",
      desc = "@ui_enable_camera_lock_target_follow_description",
      dataNode = "Controls.CameraLockTargetFollow",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLockTargetFollow",
      callback2 = "EnableCameraLockTargetFollow",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock_retarget",
      desc = "@ui_enable_camera_lock_retarget_description",
      dataNode = "Controls.CameraLockRetarget",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLockRetarget",
      callback2 = "EnableCameraLockRetarget",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock_sticky_lock",
      desc = "@ui_enable_camera_lock_sticky_lock_description",
      dataNode = "Controls.CameraLockStickyLock",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLockStickyLock",
      callback2 = "EnableCameraLockStickyLock",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock_manual_toggle",
      desc = "@ui_enable_camera_lock_manual_toggle_description",
      dataNode = "Controls.CameraLockManualToggle",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLockManualToggle",
      callback2 = "EnableCameraLockManualToggle",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_camera_lock_group_mode",
      desc = "@ui_enable_camera_lock_group_mode_description",
      dataNode = "Controls.CameraLockGroupMode",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCameraLockGroupMode",
      callback2 = "EnableCameraLockGroupMode",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_autopinObjectivesMain",
      desc = "@ui_autopinobjectivesMain_desc",
      dataNode = string.format("Misc.EnableAutoPinningObjectives.%s", eObjectiveType_MainStoryQuest),
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoPinningObjectivesMain",
      callback2 = "EnableAutoPinningObjectivesMain",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-auto-pin-options"
    },
    {
      text = "@ui_autopinobjectivesSide",
      desc = "@ui_autopinobjectivesSide_desc",
      dataNode = string.format("Misc.EnableAutoPinningObjectives.%s", eObjectiveType_Objective),
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoPinningObjectivesObjective",
      callback2 = "EnableAutoPinningObjectivesObjective",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-auto-pin-options"
    },
    {
      text = "@ui_autopinObjectivesFaction",
      desc = "@ui_autopinobjectivesFaction_desc",
      dataNode = string.format("Misc.EnableAutoPinningObjectives.%s", eObjectiveType_Mission),
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoPinningObjectivesMission",
      callback2 = "EnableAutoPinningObjectivesMission",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-auto-pin-options"
    },
    {
      text = "@ui_autopinObjectivesComm",
      desc = "@ui_autopinobjectivesComm_desc",
      dataNode = string.format("Misc.EnableAutoPinningObjectives.%s", eObjectiveType_CommunityGoal),
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoPinningObjectivesCommunity",
      callback2 = "EnableAutoPinningObjectivesCommunity",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-auto-pin-options"
    },
    {
      text = "@ui_autopinObjectivesCrafting",
      desc = "@ui_autopinobjectivesCrafting_desc",
      dataNode = string.format("Misc.EnableAutoPinningObjectives.%s", eObjectiveType_Crafting),
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAutoPinningObjectivesCrafting",
      callback2 = "EnableAutoPinningObjectivesCrafting",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-auto-pin-options"
    }
  }
  self.AudioOutputData = {
    {
      text = "@ui_audiooutput_speakers",
      value = eAudioSetupType_Speakers
    },
    {
      text = "@ui_audiooutput_headphones",
      value = eAudioSetupType_Headphones
    }
  }
  self.AudioListItemData = {
    {
      text = "@ui_mastervolume",
      desc = "@ui_mastervolume_desc",
      dataNode = "Audio.MasterVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetMasterVolume"
    },
    {
      text = "@ui_cinevolume",
      desc = "@ui_cinevolume_desc",
      dataNode = "Audio.CINEVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetCINEVolume"
    },
    {
      text = "@ui_sfxvolume",
      desc = "@ui_sfxvolume_desc",
      dataNode = "Audio.SFXVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetSFXVolume"
    },
    {
      text = "@ui_ambVolume",
      desc = "@ui_ambVolume_desc",
      dataNode = "Audio.AmbVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetAmbVolume"
    },
    {
      text = "@ui_vocalsvolume",
      desc = "@ui_vocalsvolume_desc",
      dataNode = "Audio.VocalsVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetVocalsVolume"
    },
    {
      text = "@ui_vovolume",
      desc = "@ui_vovolume_desc",
      dataNode = "Audio.VoVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetVoVolume"
    },
    {
      text = "@ui_musicvolume",
      desc = "@ui_musicvolume_desc",
      dataNode = "Audio.MusicVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetMusicVolume"
    },
    {
      text = "@ui_ambientmusicvolume",
      desc = "@ui_ambientmusicvolume_desc",
      dataNode = "Audio.AmbientVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetAmbientMusicVolume"
    },
    {
      text = "@ui_uivolume",
      desc = "@ui_uivolume_desc",
      dataNode = "Audio.UiVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetUiVolume"
    },
    {
      text = "@ui_loudnesslevel",
      desc = "@ui_loudnesslevel_desc",
      dataNode = "Audio.LoudnessLevel",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetLoudnessLevel"
    },
    {
      text = "@ui_outputconfiguration",
      desc = "@ui_outputconfiguration_desc",
      dataNode = "Audio.OutputConfiguration",
      inputType = self.INPUT_TYPE_DROPDOWN,
      dropdownData = self.AudioOutputData,
      callback = "SetOutputConfiguration",
      featureFlag = "UIFeatures.g_uiEnableHeadphoneSpatialization"
    },
    {
      text = "@ui_enable_audio_window_unfocus",
      desc = "@ui_enable_audio_window_unfocus_desc",
      dataNode = "Audio.IgnoreWindowFocus",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableIgnoreWindowFocus",
      callback2 = "EnableIgnoreWindowFocus",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    }
  }
  self.VoipModeData = {
    {
      text = "@ui_voicechatmode_enabled",
      value = eVoiceChatMode_Enabled
    },
    {
      text = "@ui_voicechatmode_grouponly",
      value = eVoiceChatMode_Only_2d
    },
    {
      text = "@ui_voicechatmode_disabled",
      value = eVoiceChatMode_Disabled
    }
  }
  self.VoipInputModeData = {
    {
      text = "@ui_voicechatinputmode_pushtotalk",
      value = eVoiceChatInputMode_Push_To_Talk
    },
    {
      text = "@ui_voicechatinputmode_pushtotalk_toggle",
      value = eVoiceChatInputMode_Push_To_Talk_Toggle
    },
    {
      text = "@ui_voicechatinputmode_alwayson",
      value = eVoiceChatInputMode_Always_On
    }
  }
  self.CommsListItemData = {
    {
      text = "@ui_voicechatmode",
      desc = "@ui_voicechatmode_desc",
      dataNode = "Voip.Mode",
      inputType = self.INPUT_TYPE_DROPDOWN,
      dropdownData = self.VoipModeData,
      callback = "SetVoipMode"
    },
    {
      text = "@ui_speaker",
      desc = "@ui_speaker_desc",
      dataNode = "Voip.OutputDevices",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetVoipOutputDevice"
    },
    {
      text = "@ui_receivevolume",
      desc = "@ui_receivevolume_desc",
      dataNode = "Voip.OutputVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetVoipOutVolume"
    },
    {
      text = "@ui_microphone",
      desc = "@ui_microphone_desc",
      dataNode = "Voip.InputDevices",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetVoipInputDevice"
    },
    {
      text = "@ui_microphonevolume",
      desc = "@ui_microphonevolume_desc",
      dataNode = "Voip.InputVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetVoipMicVolume"
    },
    {
      text = "@ui_microphonesensitivity",
      desc = "@ui_microphonesensitivity_desc",
      dataNode = "Voip.InputSensitivity",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetVoipMicSensitivity"
    },
    {
      text = "@ui_voicechatinputmode",
      desc = "@ui_voicechatinputmode_desc",
      dataNode = "Voip.InputMode",
      inputType = self.INPUT_TYPE_DROPDOWN,
      dropdownData = self.VoipInputModeData,
      callback = "SetVoipInputMode"
    },
    {
      text = "@ui_chat_font_size_options",
      desc = "@ui_options_chat_font_size_desc",
      dataNode = "Chat.ChatFontSize",
      inputType = self.INPUT_TYPE_SLIDER,
      minValue = 16,
      maxValue = 32,
      callback = "SetChatSize"
    },
    {
      text = "@ui_chat_message_fade_delay_options",
      desc = "@ui_chat_message_fade_delay_desc",
      dataNode = "Chat.ChatMessageFadeDelay",
      inputType = self.INPUT_TYPE_SLIDER,
      minValue = 0,
      maxValue = 5 * timeHelpers.secondsInMinute,
      callback = "SetChatFadeDelay"
    },
    {
      text = "@ui_chat_message_background_opacity_options",
      desc = "@ui_chat_message_background_opacity_desc",
      dataNode = "Chat.ChatMessageBackgroundOpacity",
      inputType = self.INPUT_TYPE_SLIDER,
      minValue = 0,
      maxValue = 100,
      callback = "SetChatBackgroundOpacity"
    },
    {
      text = "@ui_chat_message_gameplay_opacity_options",
      desc = "@ui_chat_message_gameplay_opacity_desc",
      dataNode = "Chat.ChatMessageGameplayOpacity",
      inputType = self.INPUT_TYPE_SLIDER,
      minValue = 0,
      maxValue = 100,
      callback = "SetChatGameplayOpacity"
    },
    {
      text = "@ui_profanity_filter",
      desc = "@ui_profanity_filter_desc",
      dataNode = "Accessibility.ChatProfanityFilter",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatProfanityFilter",
      callback2 = "EnableChatProfanityFilter",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_chat_enable_alerts_options",
      desc = "@ui_chat_enable_alerts_desc",
      dataNode = "Chat.ChatEnableAlerts",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatAlerts",
      callback2 = "EnableChatAlerts",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_chat_enable_close_after_send_options",
      desc = "@ui_chat_enable_close_after_send_desc",
      dataNode = "Chat.ChatCloseAfterSending",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatCloseOnSend",
      callback2 = "EnableChatCloseOnSend",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_chat_enable_always_show_time_options",
      desc = "@ui_chat_enable_always_show_time_options_desc",
      dataNode = "Chat.ChatAlwaysShowTimestamps",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatTime",
      callback2 = "EnableChatTime",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_chat_enable_color_messages_options",
      desc = "@ui_chat_enable_color_messages_options_desc",
      dataNode = "Chat.ChatColorMessageToChannel",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatColorMessage",
      callback2 = "EnableChatColorMessage",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    }
  }
  self.SocialListItemData = {
    {
      text = "@ui_streamermode_ui",
      desc = "@ui_streamermode_ui_desc",
      dataNode = "Social.StreamerModeUI",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableStreamerModeUI",
      callback2 = "EnableStreamerModeUI",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    }
  }
  self.PreferencesListItemData = {
    {
      text = "@ui_language",
      desc = "@ui_language_desc",
      dataNode = "Localization.LanguageList",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetLanguage",
      featureFlag = "UIFeatures.g_uiEnableLanguageSettings"
    },
    {
      text = "@ui_profanity_filter",
      desc = "@ui_profanity_filter_desc",
      dataNode = "Accessibility.ChatProfanityFilter",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableChatProfanityFilter",
      callback2 = "EnableChatProfanityFilter",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_subtitles",
      desc = "@ui_subtitles_desc",
      dataNode = "Accessibility.Subtitles",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableSubtitles",
      callback2 = "EnableSubtitles",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_metaachievementpopups",
      desc = "@ui_metaachievementpopups_desc",
      dataNode = "Misc.MetaAchievementPopupsEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableMetaAchievementPopups",
      callback2 = "EnableMetaAchievementPopups",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_bandwidthmode",
      desc = "@ui_bandwidthmode_desc",
      dataNode = "Network.BandwidthMode",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetBandwidthMode",
      featureFlag = "UIFeatures.g_uiBandwidthModeSetting",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        }
      }
    },
    {
      text = "@ui_analyticsenabled",
      desc = "@ui_analyticsenabled_desc",
      dataNode = "Misc.AnalyticsEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableAnalytics",
      callback2 = "EnableAnalytics",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_options_take_exit_survey",
      desc = "@ui_options_take_exit_survey_desc",
      dataNode = "Misc.ExitSurveyEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableExitSurvey",
      callback2 = "EnableExitSurvey",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-exit-survey"
    }
  }
  self.WindowModeData = {
    {
      text = "@ui_fullscreen",
      value = self.DISPLAY_MODE_FULLSCREEN
    },
    {
      text = "@ui_windowed",
      value = self.DISPLAY_MODE_WINDOWED
    }
  }
  self.VisualListItemData = {
    {
      text = "@ui_window_mode",
      desc = "@ui_window_mode_desc",
      dataNode = "Video.WindowMode",
      inputType = self.INPUT_TYPE_DROPDOWN,
      dropdownData = self.WindowModeData,
      callback = "SetWindowMode"
    },
    {
      text = "@ui_resolution",
      desc = "@ui_resolution_desc",
      dataNode = "Video.Resolution",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetResolution"
    },
    {
      text = "@ui_options_gamma",
      desc = "@ui_options_gamma_desc",
      dataNode = "Video.Gamma",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetGamma",
      minValue = 0,
      maxValue = 200,
      featureFlag = "UIFeatures.g_uiEnableGammaSettings",
      displayToGameFunc = function(percentage)
        return percentage / 100
      end,
      gameToDisplayFunc = function(percentage)
        return percentage * 100
      end
    },
    {
      text = "@ui_options_brightness",
      desc = "@ui_options_brightness_desc",
      dataNode = "Video.Brightness",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetBrightness",
      minValue = 30,
      maxValue = 80,
      featureFlag = "UIFeatures.g_uiEnableBrightnessSettings",
      displayToGameFunc = function(percentage)
        return percentage / 100
      end,
      gameToDisplayFunc = function(percentage)
        return percentage * 100
      end
    },
    {
      text = "@ui_options_contrast",
      desc = "@ui_options_contrast_desc",
      dataNode = "Video.Contrast",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetContrast",
      minValue = 10,
      maxValue = 80,
      featureFlag = "UIFeatures.g_uiEnableContrastSettings",
      displayToGameFunc = function(percentage)
        return percentage / 100
      end,
      gameToDisplayFunc = function(percentage)
        return percentage * 100
      end
    },
    {
      text = "@ui_options_fov",
      desc = "@ui_options_fov_desc",
      dataNode = "Video.Fov",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetFov",
      minValue = 40,
      maxValue = 70
    },
    {
      text = "@ui_enable_motionBlur",
      desc = "@ui_enable_motionBlur_description",
      dataNode = "Video.MotionBlurEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableMotionBlur",
      callback2 = "EnableMotionBlur",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_uiEnableMotionBlurSettings"
    },
    {
      text = "@ui_graphics_settings",
      desc = "@ui_graphics_settings_desc",
      dataNode = "Video.GraphicsQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetGraphicsQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        },
        {
          text = "@ui_options_graphics_custom",
          data = 5
        }
      }
    },
    {
      text = "@ui_graphics_effect",
      desc = "@ui_graphics_effect_description",
      dataNode = "Video.EffectsQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetEffectsQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_lighting",
      desc = "@ui_graphics_lighting_description",
      dataNode = "Video.LightingQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetLightingQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_objects",
      desc = "@ui_graphics_objects_description",
      dataNode = "Video.ObjectsQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetObjectsQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_postprocessing",
      desc = "@ui_graphics_postprocessing_description",
      dataNode = "Video.PostProcessingQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetPostProcessingQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_shadows",
      desc = "@ui_graphics_shadows_description",
      dataNode = "Video.ShadowsQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetShadowsQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_terrain",
      desc = "@ui_graphics_terrain_description",
      dataNode = "Video.TerrainQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetTerrainQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_textures",
      desc = "@ui_graphics_textures_description",
      dataNode = "Video.TexturesQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetTexturesQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_water",
      desc = "@ui_graphics_water_description",
      dataNode = "Video.WaterQuality",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetWaterQuality",
      dropdownData = {
        {
          text = "@ui_options_graphics_low",
          data = 1
        },
        {
          text = "@ui_options_graphics_medium",
          data = 2
        },
        {
          text = "@ui_options_graphics_high",
          data = 3
        },
        {
          text = "@ui_options_graphics_vhigh",
          data = 4
        }
      },
      featureFlag = "UIFeatures.g_uiEnableAdvancedVideoSettings"
    },
    {
      text = "@ui_graphics_emote_fx",
      desc = "@ui_graphics_emote_fx_description",
      dataNode = "Video.EmoteFx",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableEmoteFx",
      callback2 = "EnableEmoteFx",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "javelin.enable-premium-emotes"
    },
    {
      text = "@ui_show_fps",
      desc = "@ui_show_fps_desc",
      dataNode = "Video.IsDisplayFrameCount",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableFrameCount",
      callback2 = "EnableFrameCount",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_enable_vsync",
      desc = "@ui_enable_vsync_description",
      dataNode = "Video.VsyncEnabled",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableVsync",
      callback2 = "EnableVsync",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_max_fps",
      desc = "@ui_max_fps_desc",
      dataNode = "Video.MaxFps",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetMaxFps",
      dropdownData = {
        {
          text = "@ui_options_graphics_30fps",
          data = 1
        },
        {
          text = "@ui_options_graphics_60fps",
          data = 2
        },
        {
          text = "@ui_options_graphics_uncappedfps",
          data = 3
        }
      }
    },
    {
      text = "@ui_nameplate_slider",
      desc = "@ui_nameplate_slider_desc",
      dataNode = "Video.NameplateQuantity",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetNameplateQuantity",
      minValue = 2,
      maxValue = 100,
      featureFlag = "UIFeatures.enableNameplateSlider"
    },
    {
      text = "@ui_cap_unfocused_fps",
      desc = "@ui_cap_unfocused_fps_desc",
      dataNode = "Video.CapUnfocusedFPS",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableCapUnfocusedFPS",
      callback2 = "EnableCapUnfocusedFPS",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_Enable_Viewport_Scale",
      desc = "@ui_Enable_Viewport_Scale_desc",
      dataNode = "Video.EnableViewportScale",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableViewportScale",
      callback2 = "EnableViewportScale",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    }
  }
  self.TwitchListItemData = {
    {
      text = "@ui_options_TwitchLogin",
      desc = "@ui_options_TwitchLogin_desc",
      dataNode = "Twitch.Login",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableTwitchLogin",
      callback2 = "EnableTwitchLogin",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on"
    },
    {
      text = "@ui_options_TwitchStreamerSpotlight",
      desc = "@ui_options_TwitchStreamerSpotlight_desc",
      dataNode = "Twitch.StreamerSpotlight",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableTwitchStreamerSpotlight",
      callback2 = "EnableTwitchStreamerSpotlight",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_enableTwitchSpotlight",
      enableNode = "Hud.LocalPlayer.Options.Twitch.Login"
    },
    {
      text = "@ui_options_TwitchHideOtherStreamers",
      desc = "@ui_options_TwitchHideOtherStreamers_desc",
      dataNode = "Twitch.HideOtherStreamers",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableTwitchHideOtherStreamers",
      callback2 = "EnableTwitchHideOtherStreamers",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_enableTwitchSpotlight",
      enableNode = "Hud.LocalPlayer.Options.Twitch.Login"
    },
    {
      text = "@ui_options_TwitchSubArmy",
      desc = "@ui_options_TwitchSubArmy_desc",
      dataNode = "Twitch.SubArmy",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableTwitchSubArmy",
      callback2 = "EnableTwitchSubArmy",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.g_enableTwitchSubArmy",
      enableNode = "Hud.LocalPlayer.Options.Twitch.Login"
    }
  }
  self.AccessibilityListItemData = {
    {
      text = "@ui_colorBlindness",
      desc = "@ui_colorBlindness_desc",
      dataNode = "Accessibility.ColorBlindness",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetColorBlindness",
      dropdownData = {
        {
          text = "@ui_options_ColorBlindness_NoFilter",
          data = 0
        },
        {
          text = "@ui_options_ColorBlindness_Protanopia",
          data = 1
        },
        {
          text = "@ui_options_ColorBlindness_Protanomaly",
          data = 2
        },
        {
          text = "@ui_options_ColorBlindness_Deuteranopia",
          data = 3
        },
        {
          text = "@ui_options_ColorBlindness_Deuteranomaly",
          data = 4
        },
        {
          text = "@ui_options_ColorBlindness_Tritanopia",
          data = 5
        },
        {
          text = "@ui_options_ColorBlindness_Tritanomaly",
          data = 6
        },
        {
          text = "@ui_options_ColorBlindness_Achromatopsia",
          data = 7
        },
        {
          text = "@ui_options_ColorBlindness_Achromatomaly",
          data = 8
        }
      }
    },
    {
      text = "@ui_textSize",
      desc = "@ui_textSize_desc",
      dataNode = "Accessibility.TextSizeOption",
      inputType = self.INPUT_TYPE_DROPDOWN,
      callback = "SetTextSize",
      dropdownData = {
        {
          text = "@ui_options_textSize_regular",
          data = eAccessibilityTextOptions_Regular
        },
        {
          text = "@ui_options_textSize_bigger",
          data = eAccessibilityTextOptions_Bigger
        }
      }
    },
    {
      text = "@ui_texttospeech",
      desc = "@ui_texttospeech_desc",
      dataNode = "Accessibility.TTS",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableTTS",
      callback2 = "EnableTTS",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.enable-tts"
    },
    {
      text = "@ui_tts_volume",
      desc = "@ui_tts_volume_desc",
      dataNode = "Accessibility.TTSVolume",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetTTSVolume",
      enableNode = "Hud.LocalPlayer.Options.Accessibility.TTS",
      maxValue = 100,
      featureFlag = "UIFeatures.enable-tts"
    },
    {
      text = "@ui_tts_rate",
      desc = "@ui_tts_rate_desc",
      dataNode = "Accessibility.TTSRate",
      inputType = self.INPUT_TYPE_SLIDER,
      callback = "SetTTSRate",
      enableNode = "Hud.LocalPlayer.Options.Accessibility.TTS",
      maxValue = 10,
      featureFlag = "UIFeatures.enable-tts"
    },
    {
      text = "@ui_speechtotext",
      desc = "@ui_speechtotext_desc",
      dataNode = "Accessibility.SpeechToText",
      inputType = self.INPUT_TYPE_TOGGLE,
      callback1 = "DisableSpeechToText",
      callback2 = "EnableSpeechToText",
      inputText1 = "@ui_off",
      inputText2 = "@ui_on",
      featureFlag = "UIFeatures.enable-speechToText"
    }
  }
  self.AboutListItemData = {
    {
      text = "@ui_termsnotice",
      desc = "@ui_termsnotice_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnTermsPressed"
    },
    {
      text = "@ui_code_of_conduct",
      desc = "@ui_code_of_conduct_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnConductPressed"
    },
    {
      text = "@ui_privacynotice",
      desc = "@ui_privacynotice_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnPrivacyPressed"
    },
    {
      text = "@ui_legalnotice",
      desc = "@ui_legalnotice_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnNoticesPressed"
    },
    {
      text = "@ui_anti-cheat",
      desc = "@ui_anti-cheat_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnAntiCheatPressed"
    },
    {
      text = "@ui_credits",
      desc = "@ui_credits_desc",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnCreditsPressed"
    },
    {
      text = string.format("Version: %s CL: %s", GameRequestsBus.Broadcast.GetVersion(), GameRequestsBus.Broadcast.GetChangelist()),
      desc = "",
      dataNode = "",
      inputType = self.INPUT_TYPE_EXTERNAL_LINK,
      callback = "OnVersionInfoPressed"
    }
  }
  self.meleeIgnoreActions = {
    {
      bindingName = "attack_shoot",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_depressed",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_hold",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_release",
      actionMapName = "player"
    },
    {bindingName = "aim_draw", actionMapName = "player"},
    {
      bindingName = "aim_draw_press",
      actionMapName = "player"
    },
    {
      bindingName = "aim_draw_release",
      actionMapName = "player"
    },
    {bindingName = "reload", actionMapName = "player"},
    {
      bindingName = "disable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "enable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "ui_interact_sec",
      actionMapName = "player"
    },
    {
      bindingName = "toggleFishingBaitWindow",
      actionMapName = "ui"
    },
    {
      bindingName = "fishing_primary",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_primary_hold",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_primary_release",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_reset",
      actionMapName = "player"
    },
    {
      bindingName = "ui_repairKitItemModifier",
      actionMapName = "ui"
    }
  }
  self.rangedIgnoreActions = {
    {
      bindingName = "attack_primary",
      actionMapName = "player"
    },
    {
      bindingName = "attack_primary_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_primary_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate_release",
      actionMapName = "player"
    },
    {bindingName = "block", actionMapName = "player"},
    {
      bindingName = "block_depressed",
      actionMapName = "player"
    },
    {
      bindingName = "disable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "enable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "ui_interact_sec",
      actionMapName = "player"
    },
    {
      bindingName = "toggleFishingBaitWindow",
      actionMapName = "ui"
    },
    {
      bindingName = "fishing_primary",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_primary_hold",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_primary_release",
      actionMapName = "player"
    },
    {
      bindingName = "fishing_reset",
      actionMapName = "player"
    },
    {
      bindingName = "ui_repairKitItemModifier",
      actionMapName = "ui"
    }
  }
  self.fishingIgnoreActions = {
    {
      bindingName = "attack_primary",
      actionMapName = "player"
    },
    {
      bindingName = "attack_primary_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_primary_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_alternate_release",
      actionMapName = "player"
    },
    {bindingName = "block", actionMapName = "player"},
    {
      bindingName = "block_depressed",
      actionMapName = "player"
    },
    {
      bindingName = "disable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "enable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "ui_interact_sec",
      actionMapName = "player"
    },
    {
      bindingName = "attack_shoot",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_depressed",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_hold",
      actionMapName = "player"
    },
    {
      bindingName = "aim_shoot_release",
      actionMapName = "player"
    },
    {bindingName = "aim_draw", actionMapName = "player"},
    {
      bindingName = "aim_draw_press",
      actionMapName = "player"
    },
    {
      bindingName = "aim_draw_release",
      actionMapName = "player"
    },
    {bindingName = "reload", actionMapName = "player"},
    {
      bindingName = "disable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "enable_grid",
      actionMapName = "player"
    },
    {
      bindingName = "ui_interact_sec",
      actionMapName = "player"
    },
    {bindingName = "ability1", actionMapName = "player"},
    {
      bindingName = "ability1_hold",
      actionMapName = "player"
    },
    {
      bindingName = "ability1_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special_release",
      actionMapName = "player"
    },
    {bindingName = "ability2", actionMapName = "player"},
    {
      bindingName = "ability2_hold",
      actionMapName = "player"
    },
    {
      bindingName = "ability2_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special3",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special3_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_special3_release",
      actionMapName = "player"
    },
    {bindingName = "ability3", actionMapName = "player"},
    {
      bindingName = "ability3_hold",
      actionMapName = "player"
    },
    {
      bindingName = "ability3_release",
      actionMapName = "player"
    },
    {
      bindingName = "attack_blockbreaker",
      actionMapName = "player"
    },
    {
      bindingName = "attack_blockbreaker_hold",
      actionMapName = "player"
    },
    {
      bindingName = "attack_blockbreaker_release",
      actionMapName = "player"
    }
  }
  self.KeyBindingListItemText1 = {
    {title = "@ui_camera"},
    {
      label = "@ui_zoom_in",
      bindingData = {
        {
          bindingName = "cam_zoom_in",
          actionMapName = "camera"
        }
      },
      ignoredData = {
        {
          bindingName = "camera_lock_next_target_cw",
          actionMapName = "combat"
        },
        {
          bindingName = "camera_lock_next_target_ccw",
          actionMapName = "combat"
        },
        {
          bindingName = "ui_scroll_up",
          actionMapName = "ui"
        },
        {
          bindingName = "ui_scroll_down",
          actionMapName = "ui"
        },
        {
          bindingName = "ui_scroll_up",
          actionMapName = "ui"
        },
        {
          bindingName = "switch_buildable_up",
          actionMapName = "ui"
        },
        {
          bindingName = "switch_buildable_dn",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_zoom_out",
      bindingData = {
        {
          bindingName = "cam_zoom_out",
          actionMapName = "camera"
        }
      },
      ignoredData = {
        {
          bindingName = "camera_lock_next_target_cw",
          actionMapName = "combat"
        },
        {
          bindingName = "camera_lock_next_target_ccw",
          actionMapName = "combat"
        },
        {
          bindingName = "ui_scroll_up",
          actionMapName = "ui"
        },
        {
          bindingName = "ui_scroll_down",
          actionMapName = "ui"
        },
        {
          bindingName = "ui_scroll_down",
          actionMapName = "ui"
        },
        {
          bindingName = "switch_buildable_up",
          actionMapName = "ui"
        },
        {
          bindingName = "switch_buildable_dn",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_zoom_modifier",
      bindingData = {
        {
          bindingName = "cam_zoom_modifer",
          actionMapName = "camera"
        }
      },
      data = " "
    },
    {
      label = "@ui_freelook",
      bindingData = {
        {
          bindingName = "camera_free_look_activate",
          actionMapName = "debug"
        },
        {
          bindingName = "camera_free_look_deactivate",
          actionMapName = "debug"
        },
        {
          bindingName = "camera_free_look_activate",
          actionMapName = "ui"
        },
        {
          bindingName = "camera_free_look_deactivate",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "quickslot-cycle-mod",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_photomode",
      bindingData = {
        {bindingName = "", actionMapName = "ui"}
      },
      overrideData = "@photomode_keybind",
      isLocked = true
    },
    {
      title = "@ui_rangedcombat"
    },
    {
      label = "@ui_shoot",
      bindingData = {
        {
          bindingName = "attack_shoot",
          actionMapName = "player"
        },
        {
          bindingName = "aim_shoot_depressed",
          actionMapName = "player"
        },
        {
          bindingName = "aim_shoot_hold",
          actionMapName = "player"
        },
        {
          bindingName = "aim_shoot_release",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.rangedIgnoreActions
    },
    {
      label = "@ui_aim",
      bindingData = {
        {bindingName = "aim_draw", actionMapName = "player"},
        {
          bindingName = "aim_draw_press",
          actionMapName = "player"
        },
        {
          bindingName = "aim_draw_release",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.rangedIgnoreActions
    },
    {
      title = "@ui_melee_combat"
    },
    {
      label = "@ui_attack",
      bindingData = {
        {
          bindingName = "attack_primary",
          actionMapName = "player"
        },
        {
          bindingName = "attack_primary_hold",
          actionMapName = "player"
        },
        {
          bindingName = "attack_primary_release",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.meleeIgnoreActions
    },
    {
      label = "@ui_block",
      bindingData = {
        {bindingName = "block", actionMapName = "player"},
        {
          bindingName = "block_depressed",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.meleeIgnoreActions
    },
    {
      label = "@ui_rolldodge",
      bindingData = {
        {bindingName = "dodge", actionMapName = "player"},
        {
          bindingName = "dodge_depressed",
          actionMapName = "player"
        },
        {bindingName = "moveup", actionMapName = "movement"},
        data = " "
      },
      ignoredData = self.meleeIgnoreActions
    },
    {
      label = "@ui_sheathe",
      bindingData = {
        {bindingName = "sheathe", actionMapName = "player"},
        {
          bindingName = "sheathe_hold",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      title = "@ui_lifestaff_combat"
    },
    {
      label = "@ui_target_self",
      bindingData = {
        {
          bindingName = "self_target",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_exit_auto_target",
      bindingData = {
        {
          bindingName = "camera_lock_toggle",
          actionMapName = "combat"
        }
      },
      data = " "
    },
    {
      label = "@ui_cycle_target_up",
      bindingData = {
        {
          bindingName = "camera_lock_next_target_cw",
          actionMapName = "combat"
        }
      },
      data = " "
    },
    {
      label = "@ui_cycle_target_down",
      bindingData = {
        {
          bindingName = "camera_lock_next_target_ccw",
          actionMapName = "combat"
        }
      },
      data = " "
    },
    {
      title = "@ui_fishing"
    },
    {
      label = "@ui_fishing_equip_action",
      bindingData = {
        {
          bindingName = "fishing_activate",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_fishing_attach_bait",
      bindingData = {
        {
          bindingName = "toggleFishingBaitWindow",
          actionMapName = "ui"
        }
      },
      data = " ",
      ignoredData = self.fishingIgnoreActions
    },
    {
      label = "@ui_fishing_action",
      bindingData = {
        {
          bindingName = "fishing_primary",
          actionMapName = "player"
        },
        {
          bindingName = "fishing_primary_hold",
          actionMapName = "player"
        },
        {
          bindingName = "fishing_primary_release",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.fishingIgnoreActions
    },
    {
      label = "@ui_fishing_reset_action",
      bindingData = {
        {
          bindingName = "fishing_reset",
          actionMapName = "player"
        }
      },
      data = " ",
      ignoredData = self.fishingIgnoreActions
    },
    {
      title = "@ui_housing"
    },
    {
      label = "@ui_house_hint_decorate",
      bindingData = {
        {
          bindingName = "housing_decorate",
          actionMapName = "housing"
        }
      },
      data = " "
    },
    {
      label = "@ui_house_hint_menu",
      bindingData = {
        {
          bindingName = "housing_menu",
          actionMapName = "housing"
        }
      },
      data = " "
    },
    {
      label = "@ui_house_hint_exit",
      bindingData = {
        {
          bindingName = "housing_exit",
          actionMapName = "housing"
        }
      },
      data = " "
    },
    {
      label = "@ui_confirm",
      bindingData = {
        {
          bindingName = "housing_confirm",
          actionMapName = "housing"
        }
      },
      data = " "
    },
    {
      label = "@ui_housing_grid_snap_hint",
      bindingData = {
        {
          bindingName = "housing_toggle_grid",
          actionMapName = "housing"
        }
      },
      data = " "
    },
    {
      label = "@ui_housing_surface_lock_hint",
      bindingData = {
        {
          bindingName = "housing_toggle_surface_lock",
          actionMapName = "housing"
        }
      },
      data = " "
    }
  }
  self.KeyBindingListItemText2 = {
    {
      title = "@ui_navigation"
    },
    {
      label = "@ui_movefoward",
      bindingData = {
        {
          bindingName = "moveforward",
          actionMapName = "movement"
        },
        {
          bindingName = "moveforward_onpress",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_movebackward",
      bindingData = {
        {bindingName = "moveback", actionMapName = "movement"},
        {
          bindingName = "moveback_onpress",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_moveleft",
      bindingData = {
        {bindingName = "moveleft", actionMapName = "movement"},
        {
          bindingName = "moveleft_onpress",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_moveright",
      bindingData = {
        {bindingName = "moveright", actionMapName = "movement"},
        {
          bindingName = "moveright_onpress",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_runtoggle",
      bindingData = {
        {bindingName = "autorun", actionMapName = "movement"}
      },
      data = " "
    },
    {
      label = "@ui_crouchtoggle",
      bindingData = {
        {
          bindingName = "crouch_toggle",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_pronetoggle",
      bindingData = {
        {
          bindingName = "prone_toggle",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_walk",
      bindingData = {
        {bindingName = "walk", actionMapName = "movement"}
      },
      data = " "
    },
    {
      label = "@ui_traverse",
      bindingData = {
        {bindingName = "jump", actionMapName = "movement"},
        {bindingName = "sprint", actionMapName = "movement"},
        {
          bindingName = "sprint_hold",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      label = "@ui_toggleMoveSpeed",
      bindingData = {
        {
          bindingName = "toggleMoveSpeed",
          actionMapName = "movement"
        }
      },
      data = " "
    },
    {
      title = "@ui_userinterface"
    },
    {
      label = "@ui_inventory",
      bindingData = {
        {
          bindingName = "toggleInventoryWindow",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_map",
      bindingData = {
        {
          bindingName = "toggleMapComponent",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_skills",
      bindingData = {
        {
          bindingName = "toggleSkillsComponent",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@objective_journal",
      bindingData = {
        {
          bindingName = "toggleJournalComponent",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_guildui",
      bindingData = {
        {
          bindingName = "toggleGuildComponent",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_warboardui",
      bindingData = {
        {
          bindingName = "toggleWarboardInGame",
          actionMapName = "ui"
        }
      },
      data = " ",
      featureFlag = "javelin.siege.enable-warboard"
    },
    {
      label = "@ui_social",
      bindingData = {
        {
          bindingName = "toggleSocialWindow",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_makecamp",
      bindingData = {
        {bindingName = "makeCampOn", actionMapName = "ui"},
        {
          bindingName = "makeCampOff",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_notificationaccept",
      bindingData = {
        {
          bindingName = "notificationAccept",
          actionMapName = "notification"
        }
      },
      data = " "
    },
    {
      label = "@ui_notificationdecline",
      bindingData = {
        {
          bindingName = "notificationDecline",
          actionMapName = "notification"
        }
      },
      data = " "
    },
    {
      label = "@ui_banneraccept",
      bindingData = {
        {
          bindingName = "bannerAccept",
          actionMapName = "banner"
        }
      },
      data = " "
    },
    {
      label = "@ui_reserved_binding_openWarTutorial",
      bindingData = {
        {
          bindingName = "openWarTutorial",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_reserved_binding_ui_repairKitItemModifier",
      bindingData = {
        {
          bindingName = "ui_repairKitItemModifier",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_reserved_binding_toggleRaidWindow",
      bindingData = {
        {
          bindingName = "toggleRaidWindow",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {title = "@ui_ping"},
    {
      label = "@ui_ping",
      bindingData = {
        {bindingName = "target_tag", actionMapName = "ui"}
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_wheel",
      bindingData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {bindingName = "target_tag", actionMapName = "ui"}
      },
      data = " "
    },
    {
      label = "@ui_ping_wheel_shout",
      bindingData = {
        {
          bindingName = "target_tag_shout",
          actionMapName = "pingwheel"
        }
      },
      data = " ",
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_ping_type_Move",
      bindingData = {
        {
          bindingName = "target_tag_move",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Attack",
      bindingData = {
        {
          bindingName = "target_tag_attack",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Someone",
      bindingData = {
        {
          bindingName = "target_tag_someone",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_NeedHelp",
      bindingData = {
        {
          bindingName = "target_tag_need_help",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_NeedHealing",
      bindingData = {
        {
          bindingName = "target_tag_need_healing",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Loot",
      bindingData = {
        {
          bindingName = "target_tag_loot",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Repair",
      bindingData = {
        {
          bindingName = "target_tag_repair",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Defend",
      bindingData = {
        {
          bindingName = "target_tag_defend",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Caution",
      bindingData = {
        {
          bindingName = "target_tag_caution",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ping_type_Danger",
      bindingData = {
        {
          bindingName = "target_tag_danger",
          actionMapName = "ui"
        }
      },
      ignoredData = {
        {
          bindingName = "target_tag_selection",
          actionMapName = "ui"
        }
      },
      data = " "
    }
  }
  self.KeyBindingListItemText3 = {
    {title = "@ui_action"},
    {
      label = "@ui_weaponcycleup",
      bindingData = {
        {
          bindingName = "quickslot-cycle-up",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_weaponcycledown",
      bindingData = {
        {
          bindingName = "quickslot-cycle-down",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_weaponcyclemod",
      bindingData = {
        {
          bindingName = "quickslot-cycle-mod",
          actionMapName = "player"
        }
      },
      ignoredData = {
        {
          bindingName = "camera_free_look_activate",
          actionMapName = "debug"
        },
        {
          bindingName = "camera_free_look_deactivate",
          actionMapName = "debug"
        },
        {
          bindingName = "camera_free_look_activate",
          actionMapName = "ui"
        },
        {
          bindingName = "camera_free_look_deactivate",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_swapweapon",
      bindingData = {
        {
          bindingName = "quickslot-weaponSwap",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_weapon1",
      bindingData = {
        {
          bindingName = "quickslot-weapon1",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_weapon2",
      bindingData = {
        {
          bindingName = "quickslot-weapon2",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_consumable1",
      bindingData = {
        {
          bindingName = "quickslot-consumable-1",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_consumable2",
      bindingData = {
        {
          bindingName = "quickslot-consumable-2",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_consumable3",
      bindingData = {
        {
          bindingName = "quickslot-consumable-3",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_consumable4",
      bindingData = {
        {
          bindingName = "quickslot-consumable-4",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_ability1",
      bindingData = {
        {bindingName = "ability1", actionMapName = "player"},
        {
          bindingName = "ability1_hold",
          actionMapName = "player"
        },
        {
          bindingName = "ability1_release",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special_hold",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special_release",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_ability2",
      bindingData = {
        {bindingName = "ability2", actionMapName = "player"},
        {
          bindingName = "ability2_hold",
          actionMapName = "player"
        },
        {
          bindingName = "ability2_release",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special3",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special3_hold",
          actionMapName = "player"
        },
        {
          bindingName = "attack_special3_release",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_ability3",
      bindingData = {
        {bindingName = "ability3", actionMapName = "player"},
        {
          bindingName = "ability3_hold",
          actionMapName = "player"
        },
        {
          bindingName = "ability3_release",
          actionMapName = "player"
        },
        {
          bindingName = "attack_blockbreaker",
          actionMapName = "player"
        },
        {
          bindingName = "attack_blockbreaker_hold",
          actionMapName = "player"
        },
        {
          bindingName = "attack_blockbreaker_release",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_interact",
      bindingData = {
        {
          bindingName = "ui_interact",
          actionMapName = "ui"
        },
        {
          bindingName = "ui_interact_press_only",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_interactdetailed",
      bindingData = {
        {
          bindingName = "ui_interact_sec",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_giveup",
      bindingData = {
        {bindingName = "give_up", actionMapName = "player"}
      },
      data = " ",
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {title = "@ui_social"},
    {
      label = "@ui_chat",
      bindingData = {
        {
          bindingName = "toggleChatComponent",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_chat_command",
      bindingData = {
        {
          bindingName = "toggleChatComponentSlash",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_pushtotalk",
      bindingData = {
        {
          bindingName = "toggleMicrophoneOn",
          actionMapName = "ui"
        },
        {
          bindingName = "toggleMicrophoneOff",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_emote",
      bindingData = {
        {
          bindingName = "toggleEmoteWindow",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_inspect_player",
      bindingData = {
        {
          bindingName = "social_align",
          actionMapName = "player"
        }
      },
      data = " "
    },
    {
      label = "@ui_toggle_pvp",
      bindingData = {
        {
          bindingName = "togglePvpFlag",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      label = "@ui_duel_forfeit_title",
      bindingData = {
        {
          bindingName = "duel_forfeit",
          actionMapName = "ui"
        }
      },
      data = " "
    },
    {
      title = "@ui_dialogue"
    },
    {
      label = "@ui_dialogueoption1",
      bindingData = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption2",
      bindingData = {
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption3",
      bindingData = {
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption4",
      bindingData = {
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption5",
      bindingData = {
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption6",
      bindingData = {
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption7",
      bindingData = {
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption8",
      bindingData = {
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption9",
      bindingData = {
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    },
    {
      label = "@ui_dialogueoption10",
      bindingData = {
        {
          bindingName = "dialogueOption10",
          actionMapName = "dialogue"
        }
      },
      data = " ",
      disallowedConflicts = {
        {
          bindingName = "dialogueOption1",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption2",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption3",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption4",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption5",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption6",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption7",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption8",
          actionMapName = "dialogue"
        },
        {
          bindingName = "dialogueOption9",
          actionMapName = "dialogue"
        }
      },
      isGloballyIgnored = true,
      allowConflicts = true
    }
  }
  self.KeyBindingListItemGroups = {
    self.KeyBindingListItemText1,
    self.KeyBindingListItemText2,
    self.KeyBindingListItemText3
  }
  self.globallyIgnoredKeybinds = {
    {
      bindingName = "openStyleGuide",
      actionMapName = "ui"
    },
    {
      bindingName = "toggleMenuComponentF10",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_quickMoveItemModifierDown",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_quickMoveItemModifierUp",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_lshift_down",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_lshift_up",
      actionMapName = "ui"
    },
    {bindingName = "sprint", actionMapName = "movement"},
    {
      bindingName = "sprint_hold",
      actionMapName = "movement"
    },
    {
      bindingName = "sprint_held_delay",
      actionMapName = "movement"
    },
    {bindingName = "shift_mod", actionMapName = "movement"},
    {bindingName = "ui_lctrl", actionMapName = "ui"},
    {
      bindingName = "ui_scroll_up",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_scroll_down",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_splitItemStackModifierDown",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_splitItemStackModifierUp",
      actionMapName = "ui"
    },
    {
      bindingName = "toggle_free_cam",
      actionMapName = "camera"
    },
    {
      bindingName = "toggle_free_cam_left_control",
      actionMapName = "camera"
    },
    {
      bindingName = "hotspot_storemodifier",
      actionMapName = "spectatorcam"
    },
    {bindingName = "movedown", actionMapName = "debug"},
    {bindingName = "movedown", actionMapName = "movement"},
    {bindingName = "unbind_key", actionMapName = "ui"},
    {
      bindingName = "quickslot-cycle-up",
      actionMapName = "player"
    },
    {
      bindingName = "quickslot-cycle-down",
      actionMapName = "player"
    },
    {
      bindingName = "cam_zoom_modifer",
      actionMapName = "camera"
    },
    {
      bindingName = "cam_zoom_in",
      actionMapName = "camera"
    },
    {
      bindingName = "cam_zoom_out",
      actionMapName = "camera"
    },
    {
      bindingName = "switch_buildable_up",
      actionMapName = "ui"
    },
    {
      bindingName = "switch_buildable_dn",
      actionMapName = "ui"
    },
    {
      bindingName = "zoom_in",
      actionMapName = "spectatorcam"
    },
    {
      bindingName = "zoom_out",
      actionMapName = "spectatorcam"
    },
    {
      bindingName = "disable_grid",
      actionMapName = "ui"
    },
    {
      bindingName = "enable_grid",
      actionMapName = "ui"
    },
    {bindingName = "reload", actionMapName = "player"},
    {
      bindingName = "ui_repairItemModifier",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_salvageItemModifier",
      actionMapName = "ui"
    },
    {
      bindingName = "ui_salvageLockItemModifier",
      actionMapName = "ui"
    },
    {
      bindingName = "rotate_character_start",
      actionMapName = "ui"
    },
    {
      bindingName = "rotate_character_end",
      actionMapName = "ui"
    },
    {bindingName = "ui_visible", actionMapName = "ui"},
    {
      bindingName = "ui_visible_mod",
      actionMapName = "ui"
    },
    {
      bindingName = "camera_lock_toggle",
      actionMapName = "combat"
    },
    {
      bindingName = "camera_lock_next_target_cw",
      actionMapName = "combat"
    },
    {
      bindingName = "camera_lock_next_target_ccw",
      actionMapName = "combat"
    },
    {
      bindingName = "self_target",
      actionMapName = "player"
    }
  }
  for _, keybindingGroups in ipairs(self.KeyBindingListItemGroups) do
    for _, keybindingData in ipairs(keybindingGroups) do
      local isEnabled = true
      if keybindingData.featureFlag then
        isEnabled = ConfigProviderEventBus.Broadcast.GetBool(keybindingData.featureFlag)
      end
      if not isEnabled or keybindingData.isGloballyIgnored then
        table.insert(self.globallyIgnoredKeybinds, keybindingData)
      end
    end
  end
  OptionsDataBus.Broadcast.InitializeSerializedOptions()
  self.mOptionsDataNode = self.dataLayer:GetDataNode(self.DATA_LAYER_OPTIONS)
  self.dataLayer:RegisterOpenEvent("Options", self.canvasId)
  for i = 1, #self.MenuButtonData do
    local enable = true
    if self.MenuButtonData[i].featureFlag then
      enable = ConfigProviderEventBus.Broadcast.GetBool(self.MenuButtonData[i].featureFlag)
    end
    self.MenuButtonData[i].isEnable = enable
  end
  for i = #self.MenuButtonData, 1, -1 do
    if not self.MenuButtonData[i].isEnable then
      table.remove(self.MenuButtonData, i)
    end
  end
  self.MenuHolder:SetListData(self.MenuButtonData, self)
  self.TabbedListHeader:SetListData(self.TabbedListHeaderData, self)
  self:BusConnect(UiSpawnerNotificationBus, self.GameplayScreenContent)
  for i = 1, #self.GameplayListItemData do
    self:SpawnSettingsSlice(self.GameplayListItemData[i], i, self.GameplayScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.PreferencesScreenContent)
  for i = 1, #self.PreferencesListItemData do
    self:SpawnSettingsSlice(self.PreferencesListItemData[i], i, self.PreferencesScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.AudioScreenContent)
  for i = 1, #self.AudioListItemData do
    self:SpawnSettingsSlice(self.AudioListItemData[i], i, self.AudioScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.CommsScreenContent)
  for i = 1, #self.CommsListItemData do
    self:SpawnSettingsSlice(self.CommsListItemData[i], i, self.CommsScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.SocialScreenContent)
  for i = 1, #self.SocialListItemData do
    self:SpawnSettingsSlice(self.SocialListItemData[i], i, self.SocialScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.VisualScreenContent)
  for i = 1, #self.VisualListItemData do
    self:SpawnSettingsSlice(self.VisualListItemData[i], i, self.VisualScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.TwitchScreenContent)
  for i = 1, #self.TwitchListItemData do
    local enable = true
    if self.TwitchListItemData[i].featureFlag then
      enable = ConfigProviderEventBus.Broadcast.GetBool(self.TwitchListItemData[i].featureFlag)
    end
    if enable then
      self:SpawnSettingsSlice(self.TwitchListItemData[i], i, self.TwitchScreenContent)
    end
  end
  self:BusConnect(UiSpawnerNotificationBus, self.AccessibilityScreenContent)
  for i = 1, #self.AccessibilityListItemData do
    self:SpawnSettingsSlice(self.AccessibilityListItemData[i], i, self.AccessibilityScreenContent)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.AboutScreen)
  for i = 1, #self.AboutListItemData do
    self:SpawnSettingsSlice(self.AboutListItemData[i], i, self.AboutScreen)
  end
  local maxKeybindingElements = 0
  for i = 1, #self.KeyBindingListItemGroups do
    self:BusConnect(UiSpawnerNotificationBus, self.KeybindSections[i - 1])
    for j = 1, #self.KeyBindingListItemGroups[i] do
      local keyData = self.KeyBindingListItemGroups[i][j]
      local spawnKeybinding = true
      if keyData.featureFlag then
        spawnKeybinding = ConfigProviderEventBus.Broadcast.GetBool(keyData.featureFlag)
      end
      if spawnKeybinding == true then
        maxKeybindingElements = maxKeybindingElements + 1
        local data = {
          groupIndex = i,
          groupItemindex = j,
          itemIndex = maxKeybindingElements,
          sectionIndex = i,
          sectionEntityId = self.KeybindSections[i - 1]
        }
        self:SpawnSlice(self.KeybindSections[i - 1], "LyShineUI\\Options\\KeyBindingListItem", self.OnKeyBindingElementSpawned, data)
      end
    end
  end
  self.KeybindResetButton:OnInit()
  self.KeybindResetButton:SetCallback(self.ResetKeybindings, self)
  self.KeybindResetButton:SetText("@ui_restore_defaults")
  self.GameplayResetButton:OnInit()
  self.GameplayResetButton:SetCallback(self.ResetGameplaySettings, self)
  self.GameplayResetButton:SetText("@ui_restore_defaults")
  self.AudioResetButton:OnInit()
  self.AudioResetButton:SetCallback(self.ResetAudioSettings, self)
  self.AudioResetButton:SetText("@ui_restore_defaults")
  self.CommunicationsResetButton:OnInit()
  self.CommunicationsResetButton:SetCallback(self.ResetCommunicationSettings, self)
  self.CommunicationsResetButton:SetText("@ui_restore_defaults")
  self.SocialResetButton:OnInit()
  self.SocialResetButton:SetCallback(self.ResetSocialSettings, self)
  self.SocialResetButton:SetText("@ui_restore_defaults")
  self.VisualsResetButton:OnInit()
  self.VisualsResetButton:SetCallback(self.ResetVisualSettings, self)
  self.VisualsResetButton:SetText("@ui_restore_defaults")
  self.PreferencesResetButton:OnInit()
  self.PreferencesResetButton:SetCallback(self.ResetPreferencesSettings, self)
  self.PreferencesResetButton:SetText("@ui_restore_defaults")
  self.TwitchResetButton:OnInit()
  self.TwitchResetButton:SetCallback(self.ResetTwitchSettings, self)
  self.TwitchResetButton:SetText("@ui_restore_defaults")
  self.AccessibilityResetButton:OnInit()
  self.AccessibilityResetButton:SetCallback(self.ResetAccessibilitySettings, self)
  self.AccessibilityResetButton:SetText("@ui_restore_defaults")
  self.keybindingContentStartHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.KeyBindingScreenScrollableContent)
  UiElementBus.Event.SetIsEnabled(self.GameplayScreen, false)
  UiElementBus.Event.SetIsEnabled(self.VisualScreen, false)
  UiElementBus.Event.SetIsEnabled(self.AudioScreen, false)
  UiElementBus.Event.SetIsEnabled(self.PreferencesScreen, false)
  UiElementBus.Event.SetIsEnabled(self.CommsScreen, false)
  UiElementBus.Event.SetIsEnabled(self.SocialScreen, false)
  UiElementBus.Event.SetIsEnabled(self.TwitchScreen, false)
  UiElementBus.Event.SetIsEnabled(self.AccessibilityScreen, false)
  UiElementBus.Event.SetIsEnabled(self.AboutScreen, false)
  UiElementBus.Event.SetIsEnabled(self.KeyBindingScreen, false)
  self:SetScreenVisible(false)
  for i = 0, #self.ScrollWheelHelpers do
    self.scrollHelperStepValues[i] = UiScrollBarMouseWheelBus.Event.GetWheelStepValue(self.ScrollWheelHelpers[i])
  end
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableHeadphoneSpatialization") then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
      if isSet then
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Audio.OutputConfiguration", function(self, config)
          self.audioHelper:onOutputConfigurationChanged(config)
        end)
      end
    end)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, languageSelected)
    if not languageSelected then
      return
    end
    languageSelected = string.gsub(languageSelected, "-", "_")
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Language", languageSelected)
    for _, keyBindingListItem in pairs(self.mKeyBindingScreenListItems) do
      keyBindingListItem:UpdateKeybinding()
    end
    local optionsEntityLists = {
      self.mGameplayScreenListItems,
      self.mAudioScreenListItems,
      self.mCommsScreenListItems,
      self.mSocialScreenListItems,
      self.mPreferencesScreenListItems,
      self.mVisualScreenListItems,
      self.mTwitchScreenListItems,
      self.mAccessibilityScreenListItems,
      self.mAboutScreenListItems
    }
    for _, items in ipairs(optionsEntityLists) do
      for _, optionsListItem in pairs(items) do
        optionsListItem:ResizeHeightToText()
      end
    end
  end)
  self.setChatSizeObserver = true
  self.setChatFadeDelayObserver = true
  self.setChatBackgroundOpacityObserver = true
  self.setChatGameplayOpacityObserver = true
end
function Options:SpawnSettingsSlice(data, index, screen)
  local enable = true
  if data.featureFlag then
    enable = ConfigProviderEventBus.Broadcast.GetBool(data.featureFlag)
  end
  if enable == true then
    data.itemIndex = index
    data.itemScreen = screen
    self:SpawnSlice(screen, "LyShineUI\\Options\\OptionsListItem", self.OnListItemSpawned, data)
  end
end
function Options:OnCryAction(actionName)
  self:ExitScreen()
end
function Options:ExitScreen()
  LyShineManagerBus.Broadcast.ExitState(2717041095)
  LyShineManagerBus.Broadcast.SetState(3881446394)
end
function Options:GetDataNodeFromPartial(partialPath)
  local dataPath = string.format("%s.%s", self.DATA_LAYER_OPTIONS, partialPath)
  return self.dataLayer:GetDataNode(dataPath)
end
function Options:OnListItemSpawned(entity, data)
  entity:SetText(data.text)
  entity:SetTextDescription(data.desc)
  entity:SetInputType(data.inputType)
  local buttonInputHolder = entity:GetInputHolder()
  self:BusConnect(UiSpawnerNotificationBus, buttonInputHolder)
  if data.inputType == self.INPUT_TYPE_SLIDER then
    self:SpawnSlice(buttonInputHolder, "LyShineUI\\Slices\\Slider", self.OnListItemInputSpawned, data)
  elseif data.inputType == self.INPUT_TYPE_TOGGLE then
    self:SpawnSlice(buttonInputHolder, "LyShineUI\\Slices\\Toggle", self.OnListItemInputSpawned, data)
  elseif data.inputType == self.INPUT_TYPE_DROPDOWN then
    self:SpawnSlice(buttonInputHolder, "LyShineUI\\Slices\\Dropdown", self.OnListItemInputSpawned, data)
  elseif data.inputType == self.INPUT_TYPE_TEXT then
    local dataNode
    if data.dataNode then
      dataNode = self:GetDataNodeFromPartial(data.dataNode)
    end
    entity:SetTextInput(dataNode:GetData() or "")
  elseif data.inputType == self.INPUT_TYPE_EXTERNAL_LINK then
    entity:SetCallback(data.callback, self)
  end
  if data.itemScreen == self.GameplayScreenContent then
    self.mGameplayScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.AudioScreenContent then
    self.mAudioScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.CommsScreenContent then
    self.mCommsScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.PreferencesScreenContent then
    self.mPreferencesScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.VisualScreenContent then
    self.mVisualScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.TwitchScreenContent then
    self.mTwitchScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.AccessibilityScreenContent then
    self.mAccessibilityScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.SocialScreenContent then
    self.mSocialScreenListItems[data.itemIndex] = entity
  elseif data.itemScreen == self.AboutScreen then
    self.mAboutScreenListItems[data.itemIndex] = entity
  end
end
function Options:OnListItemInputSpawned(entity, data)
  local dataNode
  if data.dataNode then
    dataNode = self:GetDataNodeFromPartial(data.dataNode)
  end
  if not self.optionEntities[data.itemScreen] then
    self.optionEntities[data.itemScreen] = {}
  end
  if not self.optionEntities[data.itemScreen][entity.entityId] then
    self.optionEntities[data.itemScreen][entity.entityId] = {entity = entity}
  end
  self.optionEntities[data.itemScreen][entity.entityId].data = data
  if data.inputType == self.INPUT_TYPE_SLIDER then
    entity:SetMultiplier(data.valueMultiplier or 1)
    entity:SetCallback(data.callback, self)
    entity:SetDisplayToGameDataFunc(data.displayToGameFunc)
    local sliderVal = dataNode:GetData() or 0
    if data.gameToDisplayFunc then
      sliderVal = data.gameToDisplayFunc(sliderVal)
    end
    if data.minValue then
      entity:SetMinValue(data.minValue)
    end
    entity:SetWidth(self.mInputTypeWidth)
    entity:SetMaxValue(data.maxValue or 100)
    entity:SetSliderValue(sliderVal)
  elseif data.inputType == self.INPUT_TYPE_TOGGLE then
    entity:InitToggleState(dataNode:GetData())
    entity:SetCallback(data.callback1, data.callback2, self)
    entity:SetText(data.inputText1, data.inputText2)
    entity:SetWidth(self.mInputTypeWidth)
    if data.dataNode then
      local dataPath = string.format("%s.%s", self.DATA_LAYER_OPTIONS, data.dataNode)
      entity:SetDataNode(dataPath)
    end
    entity:SetEnablingDataNode(data.enableNode)
  elseif data.inputType == self.INPUT_TYPE_DROPDOWN then
    local listItemData, dropdownText
    if data.dataNode == "Video.Resolution" then
      local currentWidth = dataNode.Width:GetData()
      local currentHeight = dataNode.Height:GetData()
      dropdownText = currentWidth .. " x " .. currentHeight
      local isWindowedMode = self.mOptionsDataNode.Video.WindowMode:GetData() ~= 0
      listItemData = ResolutionManager:GetResolutions(self.dataLayer, isWindowedMode)
      self.mResolutionDropdown = entity
      self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Options.Video.SupportedResolutions.Count", function(self, data)
        local isWindowedMode = self.mOptionsDataNode.Video.WindowMode:GetData() ~= 0
        self:RefreshResolutionDropdown(isWindowedMode)
      end)
    elseif data.dataNode == "Voip.InputDevices" then
      local inputDevices = self.mOptionsDataNode.Voip.InputDevices
      local currentDeviceId = self.mOptionsDataNode.Voip.InputDeviceId:GetData()
      local keys = inputDevices:GetChildren()
      listItemData = {}
      for i = 1, #keys do
        local device = {}
        device.text = keys[i].Name:GetData()
        device.deviceId = keys[i].Id:GetData()
        if i == 1 or device.deviceId == currentDeviceId then
          dropdownText = device.text
        end
        table.insert(listItemData, device)
      end
    elseif data.dataNode == "Voip.OutputDevices" then
      local outputDevices = self.mOptionsDataNode.Voip.OutputDevices
      local currentDeviceId = self.mOptionsDataNode.Voip.OutputDeviceId:GetData()
      local keys = outputDevices:GetChildren()
      listItemData = {}
      for i = 1, #keys do
        local device = {}
        device.text = keys[i].Name:GetData()
        device.deviceId = keys[i].Id:GetData()
        if i == 1 or device.deviceId == currentDeviceId then
          dropdownText = device.text
        end
        table.insert(listItemData, device)
      end
    elseif data.dataNode == "Video.MaxFps" then
      local maxFps = self.mOptionsDataNode.Video.MaxFps
      local gameFps = maxFps:GetData()
      local itemIndex = 3
      if gameFps == 60 then
        itemIndex = 2
      elseif gameFps == 30 then
        itemIndex = 1
      end
      dropdownText = data.dropdownData[itemIndex].text
      listItemData = data.dropdownData
    elseif data.dataNode == "Localization.LanguageList" then
      local languageOption = self.mOptionsDataNode.Localization.LanguageList
      local languages = languageOption:GetChildren()
      listItemData = {}
      for i = 1, #languages do
        local languageEntry = {}
        languageEntry.languageId = languages[i].Id:GetData()
        languageEntry.text = "@" .. languageEntry.languageId
        table.insert(listItemData, languageEntry)
      end
      dropdownText = "@" .. self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Localization.Language")
    elseif data.dropdownData then
      local itemIndex = dataNode:GetData()
      if data.dataNode == "Video.WindowMode" or data.dataNode == "Voip.Mode" or data.dataNode == "Accessibility.ColorBlindness" or data.dataNode == "Accessibility.TextSizeOption" or data.dataNode == "Audio.OutputConfiguration" then
        itemIndex = itemIndex + 1
        dropdownText = data.dropdownData[itemIndex].text
      elseif data.dataNode == "Voip.InputMode" then
        for _, dropdownEntry in ipairs(data.dropdownData) do
          if dropdownEntry.value == itemIndex then
            dropdownText = dropdownEntry.text
            break
          end
        end
      else
        dropdownText = data.dropdownData[itemIndex].text
      end
      listItemData = data.dropdownData
    end
    entity:SetWidth(self.mInputTypeWidth)
    entity:SetDropdownScreenCanvasId(self.entityId)
    entity:SetListData(listItemData)
    entity:SetCallback(data.callback, self)
    entity:SetText(dropdownText)
    entity:SetOpenCallback(self.OnShowDropdown, self)
    entity:SetCloseCallback(self.OnHideDropdown, self)
    local defaultRows = 5
    if defaultRows > #listItemData then
      defaultRows = #listItemData
    end
    entity:SetDropdownListHeightByRows(defaultRows)
  end
  local inputHolder = UiElementBus.Event.GetParent(entity.entityId)
  local inputHolderWidth = UiTransform2dBus.Event.GetLocalWidth(inputHolder)
  local inputHolderHeight = UiTransform2dBus.Event.GetLocalHeight(inputHolder)
  local entityWidth = entity:GetWidth()
  local entityHeight = entity:GetHeight()
  local offsetPosX = inputHolderWidth - entityWidth
  local offsetPosY = (inputHolderHeight - entityHeight) / 2
  UiTransformBus.Event.SetLocalPosition(entity.entityId, Vector2(offsetPosX, offsetPosY))
end
function Options:OnShowDropdown(entity)
  for i = 0, #self.ScrollWheelHelpers do
    UiScrollBarMouseWheelBus.Event.SetWheelStepValue(self.ScrollWheelHelpers[i], 0)
  end
end
function Options:OnHideDropdown(entity)
  for i = 0, #self.ScrollWheelHelpers do
    UiScrollBarMouseWheelBus.Event.SetWheelStepValue(self.ScrollWheelHelpers[i], self.scrollHelperStepValues[i])
  end
end
function Options:OnKeyBindingElementSpawned(keyBindingListItem, data)
  self.mKeyBindingScreenListItems[data.itemIndex] = keyBindingListItem
  local itemIndex = data.itemIndex
  local groupIndex = data.groupIndex
  local groupItemIndex = data.groupItemindex
  local sectionIndex = data.sectionIndex
  local sectionEntityId = data.sectionEntityId
  local keyData = self.KeyBindingListItemGroups[groupIndex][groupItemIndex]
  if keyData.title then
    keyBindingListItem:SetTextTitle(keyData.title)
    UiLayoutCellBus.Event.SetTargetHeight(keyBindingListItem.entityId, self.mKeyBindTitleHeight)
  else
    keyBindingListItem:SetText(keyData.label)
    keyBindingListItem:SetBindingData(keyData.bindingData)
    keyBindingListItem:SetDefaultData(keyData.data)
    keyBindingListItem:SetOverrideData(keyData.overrideData)
    keyBindingListItem:SetIsLocked(keyData.isLocked)
    local ignoredData = keyData.ignoredData
    ignoredData = ignoredData or {}
    for _, keyData in ipairs(self.globallyIgnoredKeybinds) do
      if keyData.bindingData then
        for _, bindingData in ipairs(keyData.bindingData) do
          table.insert(ignoredData, bindingData)
        end
      else
        table.insert(ignoredData, keyData)
      end
    end
    keyBindingListItem:SetIgnoredData(ignoredData)
    keyBindingListItem:SetAllowConflicts(keyData.allowConflicts)
    keyBindingListItem:SetDisallowedConflictData(keyData.disallowedConflicts)
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      local isRequiredForFtue = false
      for _, binding in ipairs(keyData.bindingData) do
        if TutorialCommon:IsKeybindRequiredForFtue(binding.bindingName, binding.actionMapName) then
          isRequiredForFtue = true
          break
        end
      end
      keyBindingListItem:SetCanUnbind(not isRequiredForFtue)
    end
    keyBindingListItem:UpdateKeybinding()
    keyBindingListItem:SetOptionsCallbacks(self)
  end
  local itemSpacing = UiLayoutColumnBus.Event.GetSpacing(sectionEntityId)
  local itemHeight = keyBindingListItem:GetHeight()
  local newHeight = self["mKeyBindListHeight" .. sectionIndex] + (itemSpacing + itemHeight)
  self["mKeyBindListHeight" .. sectionIndex] = newHeight
  UiTransform2dBus.Event.SetLocalHeight(sectionEntityId, newHeight)
  local greatestHeight = self.keybindingContentStartHeight
  for i = 0, #self.KeybindSections do
    local height = UiTransform2dBus.Event.GetLocalHeight(self.KeybindSections[i])
    if greatestHeight < height then
      greatestHeight = height
    end
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.KeyBindingScreenScrollableContent, greatestHeight)
end
function Options:GetKeybindEntityTableByActionName(actionName)
  for itemIndex, keyBindEntity in pairs(self.mKeyBindingScreenListItems) do
    if keyBindEntity and keyBindEntity.bindingData then
      for i = 1, #keyBindEntity.bindingData do
        if keyBindEntity.bindingData[i].bindingName == actionName then
          return keyBindEntity
        end
      end
    end
  end
end
function Options:ShowKeyAlreadyBoundWarning(newKeybindEntity, conflictingActionNames)
  local canUnbind = true
  local numConflictingActions = 0
  local conflictingActions = {}
  local conflictingActionsText = ""
  for _, actionName in ipairs(conflictingActionNames) do
    local keybindEntity = self:GetKeybindEntityTableByActionName(actionName)
    if keybindEntity then
      local keybindText = keybindEntity:GetText()
      if keybindEntity:CanUnbindAction() then
        if not conflictingActions[keybindText] then
          conflictingActions[keybindText] = keybindEntity
          numConflictingActions = numConflictingActions + 1
          if conflictingActionsText ~= "" then
            conflictingActionsText = conflictingActionsText .. "\n"
          end
          conflictingActionsText = conflictingActionsText .. keybindText
        end
      else
        keybindEntity:FlashWarning()
        conflictingActionsText = keybindText
        canUnbind = false
        break
      end
    else
      conflictingActionsText = "@ui_reserved_binding_" .. actionName
      canUnbind = false
      break
    end
  end
  local key = newKeybindEntity:GetBindingKey()
  local keyTag = "@cc_" .. key
  local locKey = LyShineScriptBindRequestBus.Broadcast.LocalizeText(keyTag)
  if locKey == keyTag then
    locKey = key
  end
  if not canUnbind then
    newKeybindEntity:ResetBindingKey()
    local message = GetLocalizedReplacementText("@ui_binding_reserved_key_blocked", {key = locKey, actionName = conflictingActionsText})
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = message
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local title, message
  if 1 < numConflictingActions then
    title = "@ui_binding_reserved_key_title_multiple"
    message = GetLocalizedReplacementText("@ui_binding_reserved_key_message_multiple", {
      key = locKey,
      newAction = newKeybindEntity:GetText(),
      oldActions = conflictingActionsText
    })
  else
    title = "@ui_binding_reserved_key_title_single"
    message = GetLocalizedReplacementText("@ui_binding_reserved_key_message_single", {
      key = locKey,
      newAction = newKeybindEntity:GetText(),
      oldAction = conflictingActionsText
    })
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, message, self.mPopupKeyAlreadyBoundId, self, function(self, result, eventId)
    if eventId == self.mPopupKeyAlreadyBoundId then
      if result == ePopupResult_Yes then
        local skipSave = true
        for _, keybindEntity in pairs(conflictingActions) do
          keybindEntity:UnbindAction(skipSave)
        end
        newKeybindEntity:RebindAction(key)
      else
        newKeybindEntity:ResetBindingKey()
      end
    end
  end)
end
function Options:SelectKeybindingRow(entity)
  if self.mCurrentBinding and type(self.mCurrentBinding) == "table" then
    self.mCurrentBinding:OnBindingEnd()
    self.mCurrentBinding = nil
    UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", true)
    UiElementBus.Event.SetIsEnabled(self.ClickThroughCover, false)
    LyShineManagerBus.Broadcast.SetIsKeybinding(false)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.KeyBindingScreenScrollMouseHelper, true)
  else
    LyShineManagerBus.Broadcast.SetIsKeybinding(true)
    self.mCurrentBinding = entity
    self.mCurrentBinding:OnBindingStart()
    UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", false)
    UiElementBus.Event.SetIsEnabled(self.ClickThroughCover, true)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.KeyBindingScreenScrollMouseHelper, false)
  end
end
function Options:ForceStopBinding()
  if self.mCurrentBinding then
    self:SelectKeybindingRow(self.mCurrentBinding)
  end
end
function Options:ResetKeybindings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetKeyBindingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetKeyBindingsId then
      self:ForceStopBinding()
      GameRequestsBus.Broadcast.ResetActionMaps()
      for i = 1, #self.mKeyBindingScreenListItems do
        local currentItem = self.mKeyBindingScreenListItems[i]
        currentItem:UpdateKeybinding()
      end
    end
  end)
end
function Options:SetScreenVisible(isVisible)
  local animDuration = 0.8
  if isVisible == true then
    self.ScriptedEntityTweener:Play(self.Properties.MenuHolder, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.MenuHolder:SetSelected(1)
    self.TabbedListHeader:SetSelected(1)
  else
    self.ScriptedEntityTweener:Play(self.Properties.MenuHolder, 0.3, {opacity = 0, ease = "QuadOut"})
    self.MenuHolder:SetUnselected()
    self.TabbedListHeader:SetUnselected()
  end
end
function Options:OpenCommsScreen()
  for i = 1, #self.MenuButtonData do
    if self.MenuButtonData[i].screen == self.CommsScreen then
      self.MenuHolder:SetSelected(i)
      return
    end
  end
end
function Options:SetSelectedScreenVisible(entity)
  if self.mCurrentSelectedScreen ~= nil then
    UiElementBus.Event.SetIsEnabled(self.mCurrentSelectedScreen, false)
  end
  local buttonIndex = entity:GetIndex()
  local screenToShow = self.MenuButtonData[buttonIndex].screen
  self.mCurrentSelectedScreen = screenToShow
  UiElementBus.Event.SetIsEnabled(screenToShow, true)
  self:ForceCloseListItem()
  UiScrollBoxBus.Event.SetScrollOffsetY(screenToShow, 0)
  if screenToShow == self.KeyBindingScreen then
    self:SetKeybindingScreenVisible()
    UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.KeyBindingScreenScrollableContent, 0)
  elseif screenToShow == self.GameplayScreen then
    self:SetGameplayScreenVisible()
  elseif screenToShow == self.VisualScreen then
    self:SetVisualScreenVisible()
  elseif screenToShow == self.PreferencesScreen then
    self:SetPreferencesScreenVisible()
  elseif screenToShow == self.AudioScreen then
    self:SetAudioScreenVisible()
  elseif screenToShow == self.CommsScreen then
    self:SetCommsScreenVisible()
  elseif screenToShow == self.SocialScreen then
    self:SetSocialScreenVisible()
  elseif screenToShow == self.TwitchScreen then
    self:SetTwitchScreenVisible()
  elseif screenToShow == self.AccessibilityScreen then
    self:SetAccessibilityScreenVisible()
  elseif screenToShow == self.AboutScreen then
    self:SetAboutScreenVisible()
  end
end
function Options:SetOptionScreenVisible(screenListItems, duration, delay)
  local animDuration = duration or 0.6
  local animDelay = delay or 0.03
  for i = 1, #screenListItems do
    local currentItem = screenListItems[i]
    if currentItem then
      self.ScriptedEntityTweener:Play(currentItem.entityId, animDuration, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = animDelay * i
      })
    end
  end
  self.mCurrentSelectedScreenListItems = screenListItems
end
function Options:SetKeybindingScreenVisible()
  self:SetOptionScreenVisible(self.mKeyBindingScreenListItems, 0.8, 0)
end
function Options:SetGameplayScreenVisible()
  self:SetOptionScreenVisible(self.mGameplayScreenListItems)
end
function Options:SetVisualScreenVisible()
  self:SetOptionScreenVisible(self.mVisualScreenListItems)
end
function Options:SetPreferencesScreenVisible()
  self:SetOptionScreenVisible(self.mPreferencesScreenListItems)
end
function Options:SetAudioScreenVisible()
  self:SetOptionScreenVisible(self.mAudioScreenListItems)
end
function Options:SetCommsScreenVisible()
  self:SetOptionScreenVisible(self.mCommsScreenListItems)
end
function Options:SetSocialScreenVisible()
  self:SetOptionScreenVisible(self.mSocialScreenListItems)
end
function Options:SetTwitchScreenVisible()
  self:SetOptionScreenVisible(self.mTwitchScreenListItems)
end
function Options:SetAccessibilityScreenVisible()
  self:SetOptionScreenVisible(self.mAccessibilityScreenListItems)
end
function Options:SetAboutScreenVisible()
  self:SetOptionScreenVisible(self.mAboutScreenListItems)
end
function Options:SetVoipInputDevice(entity, data)
  local deviceId = data.deviceId
  VoiceChatControlBus.Broadcast.SetCurrentInputDeviceId(deviceId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Voip.InputDeviceId", deviceId)
end
function Options:SetVoipOutputDevice(entity, data)
  local deviceId = data.deviceId
  VoiceChatControlBus.Broadcast.SetCurrentOutputDeviceId(deviceId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Voip.OutputDeviceId", deviceId)
end
function Options:SetVoipInputMode(entity, data)
  local inputMode = data.value
  VoiceChatControlBus.Broadcast.SetVoiceInputMode(inputMode)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Voip.InputMode", inputMode)
end
function Options:SetWindowMode(entity, data)
  local selectedMode = data.value
  if selectedMode == self.DISPLAY_MODE_FULLSCREEN then
    OptionsDataBus.Broadcast.GoFullscreen(false)
    self:RefreshResolutionDropdown(false)
  elseif selectedMode == self.DISPLAY_MODE_WINDOWED then
    OptionsDataBus.Broadcast.GoWindowed()
    self:RefreshResolutionDropdown(true)
  elseif selectedMode == self.DISPLAY_MODE_WINDOWED_FULLSCREEN then
    OptionsDataBus.Broadcast.GoFullscreen(true)
    self:RefreshResolutionDropdown(true)
  end
end
function Options:RefreshResolutionDropdown(isWindowMode)
  local listItemData = ResolutionManager:GetResolutions(self.dataLayer, isWindowMode)
  self.mResolutionDropdown:SetListData(listItemData)
end
function Options:SetResolution(entity, data)
  local resolutionNode = self:GetDataNodeFromPartial("Video.Resolution")
  self.mLastResolution = {
    resolutionNode.Width:GetData(),
    resolutionNode.Height:GetData()
  }
  self.mLastResolutionData = self.mResolutionDropdown:GetPreviousSelectedItemData()
  if self.mLastResolution[1] == data.width and self.mLastResolution[2] == data.height then
    return
  end
  local width = data.width
  local height = data.height
  OptionsDataBus.Broadcast.SetResolution(width, height)
  self.mIsPopupEnabled = true
  self.mPopupTimeDisplayed = 0
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_resolution_popup_title", "@ui_resolution_popup_title_message", self.mPopupEventId, self, self.OnPopupResult)
  if not self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  end
end
function Options:OnTick(deltaTime, timePoint)
  if self.mIsPopupEnabled then
    self.mPopupTimeDisplayed = self.mPopupTimeDisplayed + deltaTime
    if self.mPopupTimeDisplayed > self.mPopupRevertTime then
      UiPopupBus.Broadcast.HidePopup(self.mPopupEventId)
    end
  end
end
function Options:OnPopupResult(result, eventId)
  if eventId == self.mPopupEventId then
    if result ~= ePopupResult_Yes and self.mLastResolution then
      OptionsDataBus.Broadcast.SetResolution(self.mLastResolution[1], self.mLastResolution[2])
      self.mResolutionDropdown:SetSelectedItemData(self.mLastResolutionData)
      self.mLastResolution = nil
    end
    self.mIsPopupEnabled = false
  end
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function Options:EnableFrameCount(entityId)
  OptionsDataBus.Broadcast.SetShowFrameCount(true)
end
function Options:DisableFrameCount(entityId)
  OptionsDataBus.Broadcast.SetShowFrameCount(false)
end
function Options:EnableMotionBlur()
  OptionsDataBus.Broadcast.SetMotionBlur(true)
end
function Options:DisableMotionBlur()
  OptionsDataBus.Broadcast.SetMotionBlur(false)
end
function Options:EnableEmoteFx()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.EmoteFx", true)
end
function Options:DisableEmoteFx()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.EmoteFx", false)
end
function Options:EnableVsync(entityId)
  OptionsDataBus.Broadcast.SetVsync(true)
end
function Options:DisableVsync(entityId)
  OptionsDataBus.Broadcast.SetVsync(false)
end
function Options:DisableCapUnfocusedFPS(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.CapUnfocusedFPS", false)
end
function Options:EnableCapUnfocusedFPS(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.CapUnfocusedFPS", true)
end
function Options:DisableViewportScale(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.EnableViewportScale", false)
end
function Options:EnableViewportScale(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.EnableViewportScale", true)
end
function Options:UpdateGraphicsQualitySettings(globalSettingOnly)
  for _, entry in pairs(self.optionEntities[self.VisualScreenContent]) do
    if globalSettingOnly == true then
      if entry.data.dataNode == "Video.GraphicsQuality" then
        self:OnListItemInputSpawned(entry.entity, entry.data)
        return
      end
    elseif entry.data.dataNode == "Video.EffectsQuality" or entry.data.dataNode == "Video.LightingQuality" or entry.data.dataNode == "Video.ObjectsQuality" or entry.data.dataNode == "Video.PostProcessingQuality" or entry.data.dataNode == "Video.ShadowsQuality" or entry.data.dataNode == "Video.TerrainQuality" or entry.data.dataNode == "Video.TexturesQuality" or entry.data.dataNode == "Video.WaterQuality" then
      self:OnListItemInputSpawned(entry.entity, entry.data)
    end
  end
end
function Options:SetBandwidthMode(entityId, data)
  OptionsDataBus.Broadcast.SetBandwidthMode(data.data)
end
function Options:SetGraphicsQuality(entityId, data)
  OptionsDataBus.Broadcast.SetGraphicsQuality(data.data)
  self:UpdateGraphicsQualitySettings(false)
end
function Options:DisableHudShowVitalsValues(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.HudShowVitalsValues", false)
end
function Options:EnableHudShowVitalsValues(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.HudShowVitalsValues", true)
end
function Options:DisableHudAlwaysFade(entityId, data)
  OptionsDataBus.Broadcast.SetHudAlwaysFade(false)
end
function Options:EnableHudAlwaysFade(entityId, data)
  OptionsDataBus.Broadcast.SetHudAlwaysFade(true)
end
function Options:DisableHudShowAllWeapons(entityId, data)
  OptionsDataBus.Broadcast.SetHudShowAllWeapons(false)
end
function Options:EnableHudShowAllWeapons(entityId, data)
  OptionsDataBus.Broadcast.SetHudShowAllWeapons(true)
end
function Options:DisableHudShowAbilityRadials(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.HudShowAbilityRadials", false)
end
function Options:EnableHudShowAbilityRadials(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.HudShowAbilityRadials", true)
end
function Options:DisableUseNewDamageNumbers(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.UseNewDamageNumbers", false)
end
function Options:EnableUseNewDamageNumbers(entityId, data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.UseNewDamageNumbers", true)
end
function Options:DisableDuelInvites(entityId, data)
  OptionsDataBus.Broadcast.SetGenericInviteEnabled(2612307810, false)
end
function Options:EnableDuelInvites(entityId, data)
  OptionsDataBus.Broadcast.SetGenericInviteEnabled(2612307810, true)
end
function Options:SetGamma(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    OptionsDataBus.Broadcast.SetGamma(sliderVal)
  end
end
function Options:SetBrightness(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    OptionsDataBus.Broadcast.SetBrightness(sliderVal)
  end
end
function Options:SetContrast(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    OptionsDataBus.Broadcast.SetContrast(sliderVal)
  end
end
function Options:SetFov(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.Fov", sliderVal)
  end
end
function Options:SetEffectsQuality(entityId, data)
  OptionsDataBus.Broadcast.SetEffectsQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetLightingQuality(entityId, data)
  OptionsDataBus.Broadcast.SetLightingQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetObjectsQuality(entityId, data)
  OptionsDataBus.Broadcast.SetObjectsQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetPostProcessingQuality(entityId, data)
  OptionsDataBus.Broadcast.SetPostProcessingQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetShadowsQuality(entityId, data)
  OptionsDataBus.Broadcast.SetShadowsQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetTerrainQuality(entityId, data)
  OptionsDataBus.Broadcast.SetTerrainQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetTexturesQuality(entityId, data)
  OptionsDataBus.Broadcast.SetTexturesQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetWaterQuality(entityId, data)
  OptionsDataBus.Broadcast.SetWaterQuality(data.data, true)
  OptionsDataBus.Broadcast.SetGraphicsQuality(5)
  self:UpdateGraphicsQualitySettings(true)
end
function Options:SetMaxFps(entityId, data)
  local gameFps = -1
  if data.data == 2 then
    gameFps = 60
  elseif data.data == 1 then
    gameFps = 30
  end
  OptionsDataBus.Broadcast.SetMaxFps(gameFps)
end
function Options:SendChatProfanityFilterTelemetry(enable)
  local event = UiAnalyticsEvent("change_profanity_filter")
  event:AddAttribute("Enable", enable and 1 or 0)
  event:Send()
end
function Options:EnableChatProfanityFilter()
  self:SendChatProfanityFilterTelemetry(true)
  OptionsDataBus.Broadcast.SetChatProfanityFilter(true)
end
function Options:DisableChatProfanityFilter()
  self:SendChatProfanityFilterTelemetry(false)
  OptionsDataBus.Broadcast.SetChatProfanityFilter(false)
end
function Options:EnableSubtitles()
  OptionsDataBus.Broadcast.SetSubtitles(true)
end
function Options:DisableSubtitles()
  OptionsDataBus.Broadcast.SetSubtitles(false)
end
function Options:EnableMetaAchievementPopups()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.MetaAchievementPopupsEnabled", true)
end
function Options:DisableMetaAchievementPopups()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.MetaAchievementPopupsEnabled", false)
end
function Options:EnableTwitchLogin()
  OptionsDataBus.Broadcast.SetTwitchLogin(true, true)
end
function Options:DisableTwitchLogin()
  OptionsDataBus.Broadcast.SetTwitchLogin(false, false)
end
function Options:EnableTwitchStreamerSpotlight()
  OptionsDataBus.Broadcast.SetTwitchStreamerSpotlight(true)
end
function Options:DisableTwitchStreamerSpotlight()
  OptionsDataBus.Broadcast.SetTwitchStreamerSpotlight(false)
end
function Options:EnableTwitchHideOtherStreamers()
  OptionsDataBus.Broadcast.SetTwitchHideOtherStreamers(true)
end
function Options:DisableTwitchHideOtherStreamers()
  OptionsDataBus.Broadcast.SetTwitchHideOtherStreamers(false)
end
function Options:EnableTwitchSubArmy()
  OptionsDataBus.Broadcast.SetTwitchSubArmy(true)
end
function Options:DisableTwitchSubArmy()
  OptionsDataBus.Broadcast.SetTwitchSubArmy(false)
end
function Options:EnableSpectatorPrivacy()
  OptionsDataBus.Broadcast.SetSpectatorPrivacy(true)
end
function Options:DisableSpectatorPrivacy()
  OptionsDataBus.Broadcast.SetSpectatorPrivacy(false)
end
function Options:SetColorBlindness(entityId, data)
  OptionsDataBus.Broadcast.SetColorBlindness(data.data)
end
function Options:SetTextSize(entityId, data)
  OptionsDataBus.Broadcast.SetTextSize(data.data)
end
function Options:EnableSpeechToText()
  OptionsDataBus.Broadcast.SetSpeechToTextEnabled(true)
  local event = UiAnalyticsEvent("speech_to_text")
  event:AddAttribute("enabled", 1)
  event:Send()
end
function Options:DisableSpeechToText()
  OptionsDataBus.Broadcast.SetSpeechToTextEnabled(false)
  local event = UiAnalyticsEvent("speech_to_text")
  event:AddAttribute("enabled", 0)
  event:Send()
end
function Options:EnableTTS()
  OptionsDataBus.Broadcast.SetTTSEnabled(true)
  local event = UiAnalyticsEvent("text_to_speech")
  event:AddAttribute("enabled", 1)
  event:Send()
end
function Options:DisableTTS()
  OptionsDataBus.Broadcast.SetTTSEnabled(false)
  local event = UiAnalyticsEvent("text_to_speech")
  event:AddAttribute("enabled", 0)
  event:Send()
end
function Options:SetTTSRate(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    OptionsDataBus.Broadcast.SetTTSRate(math.floor(sliderVal))
  end
end
function Options:SetTTSVolume(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    OptionsDataBus.Broadcast.SetTTSVolume(math.floor(sliderVal))
  end
end
function Options:DisableAutoTraverse()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.AutoTraverse", false)
end
function Options:EnableAutoTraverse()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.AutoTraverse", true)
end
function Options:EnableInvertLook()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.InvertLook", true)
end
function Options:DisableInvertLook()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.InvertLook", false)
end
function Options:EnableCameraShake()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraShake", true)
end
function Options:DisableCameraShake()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraShake", false)
end
function Options:EnableStrafeCamera()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.StrafeCamera", true)
end
function Options:DisableStrafeCamera()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.StrafeCamera", false)
end
function Options:EnableCameraLock()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLock", true)
end
function Options:DisableCameraLock()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLock", false)
end
function Options:EnableCameraLockFriendlies()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockFriendlies", true)
end
function Options:DisableCameraLockFriendlies()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockFriendlies", false)
end
function Options:EnableCameraLockTargetFollow()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockTargetFollow", true)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockRetarget", false)
end
function Options:DisableCameraLockTargetFollow()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockTargetFollow", false)
end
function Options:EnableCameraLockRetarget()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockRetarget", true)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockTargetFollow", false)
end
function Options:DisableCameraLockRetarget()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockRetarget", false)
end
function Options:EnableCameraLockStickyLock()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockStickyLock", true)
end
function Options:DisableCameraLockStickyLock()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockStickyLock", false)
end
function Options:EnableCameraLockManualToggle()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockManualToggle", true)
end
function Options:DisableCameraLockManualToggle()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockManualToggle", false)
end
function Options:EnableCameraLockGroupMode()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockGroupMode", true)
end
local objectiveTypeOptionToSettings = {
  [eObjectiveType_Objective] = {eObjectiveType_Objective, eObjectiveType_Journey},
  [eObjectiveType_Crafting] = {eObjectiveType_Crafting},
  [eObjectiveType_Mission] = {eObjectiveType_Mission},
  [eObjectiveType_CommunityGoal] = {eObjectiveType_CommunityGoal},
  [eObjectiveType_MainStoryQuest] = {eObjectiveType_MainStoryQuest}
}
function Options:SetObjectiveAutoPin(objectiveTypeEnum, isEnabled)
  local objectivesToSet = objectiveTypeOptionToSettings[objectiveTypeEnum]
  for _, objectiveEnum in ipairs(objectivesToSet) do
    LyShineDataLayerBus.Broadcast.SetData(string.format("Hud.LocalPlayer.Options.Misc.EnableAutoPinningObjectives.%s", objectiveEnum), isEnabled)
  end
end
function Options:DisableAutoPinningObjectivesMain()
  self:SetObjectiveAutoPin(eObjectiveType_MainStoryQuest, false)
end
function Options:EnableAutoPinningObjectivesMain()
  self:SetObjectiveAutoPin(eObjectiveType_MainStoryQuest, true)
end
function Options:DisableAutoPinningObjectivesObjective()
  self:SetObjectiveAutoPin(eObjectiveType_Objective, false)
end
function Options:EnableAutoPinningObjectivesObjective()
  self:SetObjectiveAutoPin(eObjectiveType_Objective, true)
end
function Options:DisableAutoPinningObjectivesMission()
  self:SetObjectiveAutoPin(eObjectiveType_Mission, false)
end
function Options:EnableAutoPinningObjectivesMission()
  self:SetObjectiveAutoPin(eObjectiveType_Mission, true)
end
function Options:DisableAutoPinningObjectivesCommunity()
  self:SetObjectiveAutoPin(eObjectiveType_CommunityGoal, false)
end
function Options:EnableAutoPinningObjectivesCommunity()
  self:SetObjectiveAutoPin(eObjectiveType_CommunityGoal, true)
end
function Options:DisableAutoPinningObjectivesCrafting()
  self:SetObjectiveAutoPin(eObjectiveType_Crafting, false)
end
function Options:EnableAutoPinningObjectivesCrafting()
  self:SetObjectiveAutoPin(eObjectiveType_Crafting, true)
end
function Options:DisableCameraLockGroupMode()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraLockGroupMode", false)
end
function Options:EnableAlwaysShowReticle()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.AlwaysShowReticle", true)
end
function Options:DisableAlwaysShowReticle()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.AlwaysShowReticle", false)
end
function Options:EnableShowInspectHint()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.ShowInspectHint", true)
end
function Options:DisableShowInspectHint()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.ShowInspectHint", false)
end
function Options:SetLanguage(entityId, data)
  local languageId = data.languageId
  OptionsDataBus.Broadcast.SetLanguage(languageId)
end
function Options:EnableAnalytics()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.AnalyticsEnabled", true)
  OptionsDataBus.Broadcast.SetAnalyticsEnabled(true)
end
function Options:DisableAnalytics()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.AnalyticsEnabled", false)
  OptionsDataBus.Broadcast.SetAnalyticsEnabled(false)
end
function Options:EnableExitSurvey()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled", true)
end
function Options:DisableExitSurvey()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled", false)
end
function Options:SetCameraSensitivity(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.CameraSensitivity", sliderVal)
  end
end
function Options:SetVolumeNode(sliderEntity, dataNode, eventName)
  local sliderVal = UiSliderBus.Event.GetValue(sliderEntity)
  if 0 <= sliderVal then
    self:OnVolumeChange(sliderVal, dataNode, eventName)
    LyShineDataLayerBus.Broadcast.SetData(dataNode, sliderVal)
  end
  OptionsDataBus.Broadcast.SetAudioVolumesFromUI()
  return sliderVal
end
function Options:OnVolumeChange(sliderVal, dataNode, eventName)
  sliderVal = math.floor(sliderVal)
  local currentVal = self.dataLayer:GetDataFromNode(dataNode)
  if sliderVal ~= currentVal then
    local event = UiAnalyticsEvent(eventName)
    event:AddAttribute("Volume", sliderVal)
    event:Send()
  end
end
function Options:SetNameplateQuantity(sliderEntity)
  local sliderVal = UiSliderBus.Event.GetValue(sliderEntity.entityId)
  if sliderVal then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Video.NameplateQuantity", sliderVal)
  end
end
function Options:SetMasterVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.MasterVolume", "MasterVolume")
end
function Options:SetCINEVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.CINEVolume", "CINEVolume")
end
function Options:SetSFXVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.SFXVolume", "SFXVolume")
end
function Options:SetAmbVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.AmbVolume", "AmbVolume")
end
function Options:SetVocalsVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.VocalsVolume", "VocalsVolume")
end
function Options:SetVoVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.VoVolume", "VoVolume")
end
function Options:SetUiVolume(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.UiVolume", "UiVolume")
end
function Options:SetMusicVolume(entity)
  local prevMusicVol = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.MusicVolume")
  local musicVol = self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.MusicVolume", "MusicVolume")
  local ambientVol = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.AmbientVolume")
  for entityId, entry in pairs(self.optionEntities[self.AudioScreenContent]) do
    if entry.data.callback == "SetAmbientMusicVolume" then
      local percentage
      if prevMusicVol == 0 then
        percentage = 0
      else
        percentage = ambientVol / prevMusicVol
      end
      local newValue = musicVol * percentage
      entry.entity:SetSliderValue(newValue)
      self:SetAmbientMusicVolume(entry.entity)
    end
  end
end
function Options:SetAmbientMusicVolume(entity)
  local ambientVol = UiSliderBus.Event.GetValue(entity.entityId)
  local musicVol = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.MusicVolume")
  if ambientVol > musicVol then
    entity:SetSliderValue(musicVol)
  end
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.AmbientVolume", "AmbientVolume")
end
function Options:SetLoudnessLevel(entity)
  self:SetVolumeNode(entity.entityId, "Hud.LocalPlayer.Options.Audio.LoudnessLevel", "LoudnessLevel")
end
function Options:SetOutputConfiguration(entity, data, dropdown)
  OptionsDataBus.Broadcast.SetAudioOutputConfiguration(data.value)
end
function Options:EnableIgnoreWindowFocus()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Audio.IgnoreWindowFocus", true)
end
function Options:DisableIgnoreWindowFocus()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Audio.IgnoreWindowFocus", false)
end
function Options:SetVoipMode(entity, data, dropdown)
  local mode = data.value
  if mode == VoiceChatControlBus.Broadcast.GetCurrentMode() then
    return
  end
  VoiceChatControlBus.Broadcast.SetVoiceMode(mode)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Voip.Mode", mode)
  if dropdown then
    dropdown:StartSpinner()
    self.dataLayer:RegisterDataCallback(self, self.mModeSetPath, function(self, data)
      dropdown:StopSpinner()
      self.dataLayer:UnregisterObserver(self, self.mModeSetPath)
    end)
  end
end
function Options:SetVoipSliderValue(entityId, key)
  local sliderVal = UiSliderBus.Event.GetValue(entityId)
  if 0 <= sliderVal then
    LyShineDataLayerBus.Broadcast.SetData(key, math.floor(sliderVal))
  end
  OptionsDataBus.Broadcast.SetVoipVolumesFromUI()
end
function Options:SetVoipOutVolume(entity)
  self:SetVoipSliderValue(entity.entityId, "Hud.LocalPlayer.Options.Voip.OutputVolume")
end
function Options:SetVoipMicVolume(entity)
  self:SetVoipSliderValue(entity.entityId, "Hud.LocalPlayer.Options.Voip.InputVolume")
end
function Options:SetVoipMicSensitivity(entity)
  self:SetVoipSliderValue(entity.entityId, "Hud.LocalPlayer.Options.Voip.InputSensitivity")
end
function Options:SetChatSize(entity)
  self:SetChatSlider(entity, "Hud.LocalPlayer.Options.Chat.ChatFontSize", "@ui_chat_font_size", self.setChatSizeObserver)
  self.setChatSizeObserver = false
end
function Options:SetChatFadeDelay(entity)
  self:SetChatSlider(entity, "Hud.LocalPlayer.Options.Chat.ChatMessageFadeDelay", "@ui_chat_message_fade_delay", self.setChatFadeDelayObserver)
  self.setChatFadeDelayObserver = false
end
function Options:SetChatBackgroundOpacity(entity)
  self:SetChatSlider(entity, "Hud.LocalPlayer.Options.Chat.ChatMessageBackgroundOpacity", "@ui_chat_message_background_opacity", self.setChatBackgroundOpacityObserver)
  self.setChatBackgroundOpacityObserver = false
end
function Options:SetChatGameplayOpacity(entity)
  self:SetChatSlider(entity, "Hud.LocalPlayer.Options.Chat.ChatMessageGameplayOpacity", "@ui_chat_message_gameplay_opacity", self.setChatGameplayOpacityObserver)
  self.setChatGameplayOpacityObserver = false
end
function Options:SetChatSlider(entity, dataNode, label, registerObserver)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  LyShineDataLayerBus.Broadcast.SetData(dataNode, math.floor(sliderVal))
  self:SendChatTelemetry(label, tostring(sliderVal))
  if registerObserver then
    self.dataLayer:RegisterAndExecuteDataObserver(self, dataNode, function(self, value)
      if value == nil then
        return
      end
      if value ~= entity:GetValue() then
        entity:SetSliderValue(value)
      end
    end)
  end
end
function Options:SendChatTelemetry(label, isEnabled)
  local event = UiAnalyticsEvent("Chat_AccessibilityChange")
  event:AddAttribute("Label", label)
  event:AddAttribute("Value", tostring(isEnabled))
  event:Send()
end
function Options:DisableChatAlerts()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatEnableAlerts", false)
  self:SendChatTelemetry("@ui_chat_enable_alerts", false)
end
function Options:EnableChatAlerts()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatEnableAlerts", true)
  self:SendChatTelemetry("@ui_chat_enable_alerts", true)
end
function Options:DisableChatCloseOnSend()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending", false)
  self:SendChatTelemetry("@ui_chat_enable_close_after_send", false)
end
function Options:EnableChatCloseOnSend()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending", true)
  self:SendChatTelemetry("@ui_chat_enable_close_after_send", true)
end
function Options:DisableChatTime()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatAlwaysShowTimestamps", false)
  self:SendChatTelemetry("@ui_chat_enable_always_show_time", false)
end
function Options:EnableChatTime()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatAlwaysShowTimestamps", true)
  self:SendChatTelemetry("@ui_chat_enable_always_show_time", true)
end
function Options:DisableChatColorMessage()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatColorMessageToChannel", false)
  self:SendChatTelemetry("@ui_chat_enable_color_messages", false)
end
function Options:EnableChatColorMessage()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatColorMessageToChannel", true)
  self:SendChatTelemetry("@ui_chat_enable_color_messages", true)
end
function Options:EnableStreamerModeUI()
  OptionsDataBus.Broadcast.SetStreamerModeUIEnabled(true)
end
function Options:DisableStreamerModeUI()
  OptionsDataBus.Broadcast.SetStreamerModeUIEnabled(false)
end
function Options:ResetGameplaySettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetResetGameplaySettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetResetGameplaySettingsId then
      OptionsDataBus.Broadcast.ResetGameplaySettings()
      self:ResetScreenUi(self.GameplayScreenContent)
    end
  end)
end
function Options:ResetVisualSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetVisualSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetVisualSettingsId then
      OptionsDataBus.Broadcast.ResetVisualSettings()
      self:ResetScreenUi(self.VisualScreenContent)
    end
  end)
end
function Options:ResetPreferencesSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetPreferencesSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetPreferencesSettingsId then
      OptionsDataBus.Broadcast.ResetPreferencesSettings()
      self:ResetScreenUi(self.PreferencesScreenContent)
    end
  end)
end
function Options:ResetAudioSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetAudioSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetAudioSettingsId then
      OptionsDataBus.Broadcast.ResetAudioSettings()
      self:ResetScreenUi(self.AudioScreenContent)
    end
  end)
end
function Options:ResetCommunicationSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetCommunicationSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetCommunicationSettingsId then
      OptionsDataBus.Broadcast.ResetCommunicationSettings()
      OptionsDataBus.Broadcast.ResetChatSettings()
      self:ResetScreenUi(self.CommsScreenContent)
    end
  end)
end
function Options:ResetSocialSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetSocialSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetSocialSettingsId then
      OptionsDataBus.Broadcast.ResetSocialSettings()
      self:ResetScreenUi(self.SocialScreenContent)
    end
  end)
end
function Options:ResetTwitchSettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetTwitchSettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetTwitchSettingsId then
      OptionsDataBus.Broadcast.ResetTwitchSettings()
      self:ResetScreenUi(self.TwitchScreenContent)
    end
  end)
end
function Options:ResetAccessibilitySettings()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_restore_defaults", "@ui_restore_defaults_prompt", self.mPopupResetAccessibilitySettingsId, self, function(self, result, eventId)
    if result == ePopupResult_Yes and eventId == self.mPopupResetAccessibilitySettingsId then
      OptionsDataBus.Broadcast.ResetAccessibilitySettings()
      self:ResetScreenUi(self.AccessibilityScreenContent)
    end
  end)
end
function Options:ResetScreenUi(itemScreen)
  if not self.optionEntities[itemScreen] then
    return
  end
  for _, entry in pairs(self.optionEntities[itemScreen]) do
    self:OnListItemInputSpawned(entry.entity, entry.data)
  end
end
function Options:OnTermsPressed()
  OptionsDataBus.Broadcast.OpenTermsInBrowser()
end
function Options:OnConductPressed()
  OptionsDataBus.Broadcast.OpenCodeOfConductInBrowser()
end
function Options:OnAntiCheatPressed()
  OptionsDataBus.Broadcast.OpenAntiCheatDisclosure()
end
function Options:OnVersionInfoPressed()
  OptionsDataBus.Broadcast.CopyVersionInfoToClipboard()
end
function Options:OnPrivacyPressed()
  OptionsDataBus.Broadcast.OpenPrivacyInBrowser()
end
function Options:OnNoticesPressed()
  OptionsDataBus.Broadcast.OpenNoticesInBrowser()
end
function Options:OnCreditsPressed()
  OptionsDataBus.Broadcast.OpenCreditsInBrowser()
end
function Options:ForceCloseListItem()
  if self.mCurrentSelectedListItem ~= nil then
    self.mCurrentSelectedListItem:OnUnfocus(true)
  end
end
function Options:OnAction(entityId, action)
  local currentItem = self.registrar:GetEntityTable(entityId)
  if currentItem ~= nil and currentItem.GetInputType ~= nil then
    if self.mCurrentSelectedScreenListItems ~= nil then
      for i = 1, #self.mCurrentSelectedScreenListItems do
        local listItem = self.mCurrentSelectedScreenListItems[i]
        if listItem then
          listItem:OnUnfocus()
        end
      end
    end
    self.mCurrentSelectedListItem = currentItem
  end
  return BaseScreen.OnAction(self, entityId, action)
end
function Options:CleanupScreen()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.OnClosed", true)
  self:ForceStopBinding()
  if self.mIsPopupEnabled then
    UiPopupBus.Broadcast.HidePopup(self.mPopupEventId)
  end
  if self.tickBusHandler ~= nil then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function Options:OnShutdown()
  self:CleanupScreen()
  for _, entity in pairs(self.mKeyBindingScreenListItems) do
    if entity.entityId then
      UiElementBus.Event.DestroyElement(entity.entityId)
    end
  end
  if self.optionsHandler then
    DynamicBus.Options.Disconnect(self.entityId, self)
    self.optionsHandler = nil
  end
  BaseScreen.OnShutdown(self)
  if self.escapeKeyHandlers then
    ClearTable(self.escapeKeyHandlers)
  end
end
function Options:SetEscapeButtonVisible(isVisible)
  if isVisible then
    self.ScreenHeader:SetText("@ui_exit")
    self.ScreenHeader:SetHintCallback(self.ExitScreen, self)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ScreenHeader, isVisible)
end
function Options:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
  self:SetScreenVisible(true)
  if toStateName == 2717041095 then
    self.escapeKeyHandlers = {
      self:BusConnect(CryActionNotificationsBus, "toggleMenuComponent"),
      self:BusConnect(CryActionNotificationsBus, "ui_cancel")
    }
    self:SetEscapeButtonVisible(true)
  else
    self:SetEscapeButtonVisible(false)
  end
end
function Options:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  self:SetScreenVisible(false)
  self:ForceCloseListItem()
  self:ForceStopBinding()
  if self.escapeKeyHandlers then
    for _, handlers in ipairs(self.escapeKeyHandlers) do
      self:BusDisconnect(handlers)
    end
    ClearTable(self.escapeKeyHandlers)
    self.escapeKeyHandlers = nil
  end
  self:CleanupScreen()
  OptionsDataBus.Broadcast.SerializeOptions()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
return Options
