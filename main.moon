
-- theme: alone

require "moon"

import p from moon
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

class Player
  speed: 200
  w: 32
  h: 64
  color: { 237, 139, 5 }

  new: (@x, @y) =>

  update: (dt) =>
    if keyboard.isDown "left"
      @x -= dt * @speed
    elseif keyboard.isDown "right"
      @x += dt * @speed

  draw: =>
    setColor @color
    rectangle "fill", @x, @y, @w, @h

class Game
  new: =>
    @player = Player 100, 100

  update: (dt) =>
    @player\update dt

  draw: =>
    @player\draw!

  keypressed: (key, code) =>
    os.exit! if key == "escape"

love.load = ->
  g = Game!
  love.update = g\update
  love.draw = g\draw
  love.keypressed = g\keypressed
  -- love.keyreleased = g\keyreleased

