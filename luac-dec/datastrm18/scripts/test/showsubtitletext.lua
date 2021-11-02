local ShowSubtitleText = {
  Properties = {
    duration = {
      default = 5,
      description = "change the duration of the subtitles displayed on screen",
      order = 1
    },
    locKeyTable = {
      default = "simongrey_intro_line1",
      description = "locKeyTable or Localization key found in the xml files",
      order = 2
    }
  }
}
function ShowSubtitleText:OnActivate()
  if self.Properties.locKeyTable == "" or self.Properties.locKeyTable == nil then
    Debug.Log("##### - ShowSubtitleText locKeyTable is nil")
    return
  end
  local locKey = "@" .. tostring(self.Properties.locKeyTable)
  local notificationData = NotificationData()
  local speaker = LyShineScriptBindRequestBus.Broadcast.GetAttributeValueForKey(locKey, "speaker")
  notificationData.type = "Subtitle"
  notificationData.title = speaker
  notificationData.text = locKey
  notificationData.maximumDuration = self.Properties.duration
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ShowSubtitleText:OnDeactivate()
end
return ShowSubtitleText
