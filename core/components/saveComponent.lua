local component = {
  name = "save",
  supportedElementsType = {"object", "player", "vehicle"},

  onMount = function(element)
    iprint("mount save",getTickCount())
  end,
  
  onUnmount = function(element)
    iprint("unmount save",getTickCount())
  end,
}

registerComponent(component)