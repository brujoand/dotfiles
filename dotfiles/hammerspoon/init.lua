local move = {"cmd", "shift", "ctrl"}
local control = {"option", "shift", "ctrl"}


hs.window.animationDuration = 0

hs.hotkey.bind(control, "'", function()
  hs.reload()
end)

function stretch(x,y,w,h)
  local win = hs.window.focusedWindow()
  if (win == nil) then
    hs.alert.show("Can't rezise nothing..")
    do return end
  end

  local current = win:frame()
  local screen = win:screen()
  local framesize = screen:frame()
  local target = hs.geometry.new((framesize.w * x) + framesize.x, (framesize.h * y) + framesize.y, framesize.w * w, framesize.h * h):floor()

  if (current:equals(target)) then
    throw()
  else
    win:setFrame(target)
  end
end

function throw()
  if (#hs.screen.allScreens() > 1) then
    local current = hs.screen.mainScreen()
    local win = hs.window.focusedWindow()
    if (win ~= nil) then
      local target = win:screen():next()
      win:moveToScreen(target)
    end
  end
end

-- Renize and move windows. Same key twice throws to next display
hs.hotkey.bind(move, "H", function() stretch(0,0,0.5,0.5) end)
hs.hotkey.bind(move, "T", function() stretch(0,0.5,0.5,0.5) end)
hs.hotkey.bind(move, "N", function() stretch(0.5,0.5,0.5,0.5) end)
hs.hotkey.bind(move, "S", function() stretch(0.5,0,0.5,0.5) end)
hs.hotkey.bind(move, "M", function() stretch(0,0,1,1) end)

function brightness(change)
  local current = hs.brightness.get()
  local target = current + change
  hs.brightness.set(target)
  hs.alert.show("Brightness: " .. target)
end

-- Control brightness
hs.hotkey.bind(control, "N", function() brightness(-10) end)
hs.hotkey.bind(control, "S", function() brightness(10) end)

function volume(change)
  local systemsound = hs.audiodevice.current().device
  local current = systemsound:volume()

  if(change == nil) then
    local muted = systemsound:muted()
    systemsound:setMuted(not muted)
    if (muted) then
      hs.alert.show("Volume: " .. current)
    else
      hs.alert.show("Muted")
    end
  else
    local target = current + change
    systemsound:setVolume(target)
    hs.alert.show("Volume: " .. target)
  end
end

-- Control volume
hs.hotkey.bind(control, "H", function() volume(-10) end)
hs.hotkey.bind(control, "T", function() volume(10) end)
hs.hotkey.bind(control, "C", function() volume() end)


hs.alert.show("Config loaded")
