-- luacheck: globals audio display easing graphics lfs media native network Runtime system timer transition

local Composer = require "composer"
local Physics  = require "physics"
local Score    = require "seq.score"

local scene  = Composer.newScene ()
scene.width  = display.actualContentWidth
scene.height = display.actualContentHeight
scene.center = display.contentCenterX
scene.speed  = 200
scene.spawn  = 1000 -- milliseconds
scene.consumed = {}

scene.symbols = {
  "🌰",
  "🌽",
  "🍄",
  "🍅",
}

scene.sequences = {
  {},
  {},
}

-- Sequences:
local separator = display.actualContentWidth / (#scene.sequences + 1)
for i, sequence in ipairs (scene.sequences) do
  sequence.x = display.screenOriginX + i * separator
end

function scene.create ()
  -- We need Physics started to add bodies, but we don't want the simulaton
  -- running until the scene is on the screen.
  Physics.start ()
  Physics.pause ()
  Physics.setGravity (0, 0)
  -- Background:
  scene.background = display.newImageRect ("img/background.jpg", display.actualContentWidth, display.actualContentHeight)
  scene.background.anchorX = 0
  scene.background.anchorY = 0
  scene.background.x = display.screenOriginX
  scene.background.y = display.screenOriginY
  scene.view:insert (scene.background)
  -- Score:
  scene.score  = Score {
    x = display.screenOriginX + 20,
    y = display.screenOriginY + display.actualContentHeight - 30,
  }
  scene.view:insert (scene.score.text)
  -- Generate head of each sequence:
  for _, sequence in ipairs (scene.sequences) do
    local symbol  = scene.symbols [1]
    local created = display.newText {
      text = symbol,
      font = native.systemFont,
      x    = sequence.x,
      y    = display.screenOriginY - 10,
    }
    created.symbol = symbol
    Physics.addBody (created, "kinematic", {
      radius = 10,
    })
    created:setLinearVelocity (0, scene.speed)
    sequence [0] = created
    scene.view:insert (created)
  end
end

local function frame ()
  for i, sequence in ipairs (scene.sequences) do
    local element = sequence [1]
    if  element
    and element.y > display.screenOriginY + display.actualContentHeight + 10 then
      assert (not scene.consumed [i])
      scene.consumed [i] = element
      table.remove (sequence, 1)
    end
    if sequence [1] then
      Physics.newJoint ("rope", sequence [0], sequence [1])
    end
  end
  if #scene.consumed == #scene.sequences then
    local all = true
    local symbol = scene.consumed [1].symbol
    for _, e in ipairs (scene.consumed) do
      all = all and e.symbol == symbol
    end
    if all then
      scene.score = scene.score + 1
    end
    for _, e in ipairs (scene.consumed) do
      e:removeSelf ()
    end
    scene.consumed = {}
  end
end

local function update ()
  -- Generate a new element in the sequence:
  for _, sequence in ipairs (scene.sequences) do
    local previous = sequence [#sequence]
    local symbol   = scene.symbols [math.random (1, #scene.symbols)]
    local created  = display.newText {
      text = symbol,
      font = native.systemFont,
      x    = sequence.x,
      y    = display.screenOriginY - 10,
    }
    created.symbol = symbol
    Physics.addBody (created, { density = 0 })
    sequence [#sequence+1] = created
    Physics.newJoint ("rope", previous, created)
    scene.view:insert (created)
  end
  -- -- make a crate (off-screen), position it, and rotate slightly
  -- local crate = display.newImageRect ("img/crate.png", 90, 90)
  -- crate.x =  160
  -- crate.y = -100
  -- crate.rotation = 15
  -- Physics.addBody (crate, { density = 1.0, friction = 0.3, bounce = 0.3 })
  -- -- create a grass object and add Physics (with custom shape)
  -- local grass = display.newImageRect ("img/grass.png", width, 82)
  -- grass.anchorX = 0
  -- grass.anchorY = 1
  -- --  draw the grass at the very bottom of the screen
  -- grass.x = display.screenOriginX
  -- grass.y = display.actualContentHeight + display.screenOriginY
  -- -- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
  -- local grassShape = { -center,-34, center,-34, center,34, -center,34 }
  -- Physics.addBody (grass, "static", { friction = 0.3, shape = grassShape })
  -- -- all display objects must be inserted into group
  -- scene.view:insert (grass)
  -- scene.view:insert (crate)
end

function scene.show (_, event)
  if event.phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif event.phase == "did" then
    -- Called when the scene is now on screen
    Physics.start()
    scene.timer = timer.performWithDelay (scene.spawn, update, 0)
  end
end

function scene.hide (_, event)
  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    timer.cancel (scene.timer)
    Physics.stop()
  elseif event.phase == "did" then
    -- Called when the scene is now off screen
  end
end

function scene.destroy ()
  for _, sequence in ipairs (scene.sequences) do
    sequence [0]:removeSelf ()
    for _, element in ipairs (sequence) do
      element:removeSelf ()
    end
  end
  for _, element in pairs (scene.view) do
    element:removeSelf ()
  end
end

-- Listener setup
scene:addEventListener ("create" , scene)
scene:addEventListener ("show"   , scene)
scene:addEventListener ("hide"   , scene)
scene:addEventListener ("destroy", scene)
Runtime:addEventListener ("enterFrame", frame)

return scene
