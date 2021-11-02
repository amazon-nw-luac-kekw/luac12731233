local JoinTab = {
  Properties = {
    SubscribedSection = {
      default = EntityId()
    },
    FollowedSection = {
      default = EntityId()
    },
    PublicSection = {
      default = EntityId()
    },
    WindowSubtitle = {
      default = EntityId()
    },
    LoadingContainer = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    EmptyImage = {
      default = EntityId()
    },
    DescriptionParent = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(JoinTab)
function JoinTab:OnInit()
  BaseElement.OnInit(self)
  self.allowPublicSessions = ConfigProviderEventBus.Broadcast.GetBool("javelin.twitch-subarmy-allow-public-sessions")
  self:BusConnect(TwitchSubArmyNotificationBus)
end
function JoinTab:ShowLoadingSection(show, spinner, message, emptyImage)
  UiElementBus.Event.SetIsEnabled(self.Properties.LoadingContainer, show)
  if show then
    UiTextBus.Event.SetTextWithFlags(self.Message, message, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, spinner)
    UiElementBus.Event.SetIsEnabled(self.Properties.EmptyImage, emptyImage)
    if spinner then
      self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0})
      self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {timesToPlay = -1, rotation = 359})
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionParent, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionParent, true)
  end
end
function JoinTab:HideEmptySections()
  local showSubscribed = self.SubscribedSection:ItemCount() > 0
  UiElementBus.Event.SetIsEnabled(self.Properties.SubscribedSection, showSubscribed)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.SubscribedSection, showSubscribed and -1 or 0)
  local showFollowed = 0 < self.FollowedSection:ItemCount()
  UiElementBus.Event.SetIsEnabled(self.Properties.FollowedSection, showFollowed)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.FollowedSection, showFollowed and -1 or 0)
  local showPublic = self.allowPublicSessions and 0 < self.PublicSection:ItemCount()
  UiElementBus.Event.SetIsEnabled(self.Properties.PublicSection, showPublic)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PublicSection, showPublic and -1 or 0)
end
function JoinTab:Refresh()
  self.SubscribedSection:ClearList()
  self.FollowedSection:ClearList()
  self.PublicSection:ClearList()
  self:HideEmptySections()
  self:ShowLoadingSection(true, true, "@ui_subarmy_loading_sessions", false)
  TwitchSubArmyRequestBus.Broadcast.RequestJoinableSubArmies()
end
function JoinTab:GetSubtitle()
  return self.subtitle or ""
end
function JoinTab:OnJoinableSubArmiesReceived(items)
  self.subtitle = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_subarmy_subtitle_sessions", tostring(#items))
  if UiElementBus.Event.IsEnabled(self.entityId) then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WindowSubtitle, self.subtitle, eUiTextSet_SetAsIs)
  end
  if #items == 0 then
    self:ShowLoadingSection(true, false, "@ui_subarmy_no_sessions", true)
  else
    self:ShowLoadingSection(false, false, "", false)
  end
  for i = 1, #items do
    local item = items[i]
    if item.viewType == eSubArmyViewType_Subscribers then
      self.SubscribedSection:AddItem(item)
    elseif item.viewType == eSubArmyViewType_Followers then
      self.FollowedSection:AddItem(item)
    elseif item.viewType == eSubArmyViewType_SubscribersAndFollowers then
      self.FollowedSection:AddItem(item)
    else
      if self.allowPublicSessions and item.viewType == eSubArmyViewType_Public then
        self.PublicSection:AddItem(item)
      else
      end
    end
  end
  self:HideEmptySections()
end
return JoinTab
