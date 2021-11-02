local PlaySimpleAnimation = {
  Properties = {
    TargetEntity = {
      default = EntityId(),
      order = 1
    },
    AnimDetails = {
      AnimationName = {default = "", order = 1},
      LayerId = {default = 0, order = 2},
      Looping = {default = false, order = 3},
      PlaybackSpeed = {default = 1, order = 4},
      LayerWeight = {default = 1, order = 5},
      TransitionTime = {default = 0.5, order = 6}
    }
  }
}
function PlaySimpleAnimation:OnActivate()
  animatedLayer = AnimatedLayer()
  animatedLayer.animationName = self.Properties.AnimDetails.AnimationName
  animatedLayer.layerId = self.Properties.AnimDetails.LayerId
  animatedLayer.looping = self.Properties.AnimDetails.Looping
  animatedLayer.playbackSpeed = self.Properties.AnimDetails.PlaybackSpeed
  animatedLayer.layerWeight = self.Properties.AnimDetails.LayerWeight
  animatedLayer.transitionTime = self.Properties.AnimDetails.TransitionTime
  SimpleAnimationComponentRequestBus.Event.StartAnimation(self.Properties.TargetEntity, animatedLayer)
end
return PlaySimpleAnimation
