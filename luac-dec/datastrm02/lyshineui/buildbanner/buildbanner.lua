local BuildBanner = {
  Properties = {
    BannerRoot = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(BuildBanner)
function BuildBanner:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_showBuildBanner", function(self, bannerVisible)
    UiElementBus.Event.SetIsEnabled(self.Properties.BannerRoot, bannerVisible)
  end)
end
return BuildBanner
