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
    return
  end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w * x
  f.y = max.h * y
  f.w = max.w * w
  f.h = max.h * h
  win:setFrame(f)
end


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

hs.hotkey.bind(control, "H", function() volume(-10) end)
hs.hotkey.bind(control, "T", function() volume(10) end)
hs.hotkey.bind(control, "C", function() volume() end)


hs.alert.show("Config loaded")
