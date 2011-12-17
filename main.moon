
-- theme: alone

require "moon"

import p from moon
import rectangle, setColor, getColor from love.graphics

class Game
  update: (dt) =>

  draw: =>
  keypressed: (...) =>
    p {...}


love.load = ->
  g = Game!
  love.update = g\update
  love.draw = g\draw
  love.keypressed = g\keypressed

