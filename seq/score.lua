-- luacheck: globals audio display easing graphics lfs media native network Runtime system timer transition
-- https://coronalabs.com/blog/2013/12/10/tutorial-howtosavescores/

local Json = require "json"

local Mt    = {}
local Score = setmetatable ({}, Mt)

function Mt.__call (_, options)
  options = options or {}
  local score = setmetatable ({
    value  = options.value  or 0,
    font   = options.font   or native.systemFont,
    size   = options.size   or 16,
    x      = options.x      or display.contentCenterX,
    y      = options.y      or display.contentCenterY,
    format = options.format or "%d",
    file   = options.file   or "score.json",
  }, Score)
  score.text = display.newText (string.format (score.format, score.value), score.x, score.y, score.font, score.size)
  return score
end

function Score.__tostring (score)
  assert (getmetatable (score) == Score)
  return tostring (score.value)
end

function Score.__add (score, n)
  assert (getmetatable (score) == Score)
  score.value = score.value + n
  Score.render (score)
  return score
end

function Score.__sub (score, n)
  assert (getmetatable (score) == Score)
  score.value = score.value - n
  Score.render (score)
  return score
end

function Score.__mul (score, n)
  assert (getmetatable (score) == Score)
  score.value = score.value * n
  Score.render (score)
  return score
end

function Score.__div (score, n)
  assert (getmetatable (score) == Score)
  score.value = score.value / n
  Score.render (score)
  return score
end

function Score.render (score)
  assert (getmetatable (score) == Score)
  score.text.text = string.format (score.format, score.value)
end

function Score.save (score)
  assert (getmetatable (score) == Score)
  local path = system.pathForFile (score.file, system.DocumentsDirectory)
  local file = assert (io.open (path, "w"))
  assert (file:write (Json.encode {
    score = score.value,
  }))
  assert (file:close ())
end

function Score.load (score)
  assert (getmetatable (score) == Score)
  local path = system.pathForFile (score.file, system.DocumentsDirectory)
  local file = io.open (path, "r")
  if not file then
    return
  end
  local data = file:read "*a"
  assert (file:close ())
  data = Json.decode (data)
  if not data then
    return
  end
  score.value = data.score
end

return Score
