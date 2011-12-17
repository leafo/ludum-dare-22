
-- theme: alone

require "moon"

import p from moon
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

class Vec2d
  new: (x=0, y=0) =>
    self[1] = x
    self[2] = y

  len: =>
    n = self[1]^2 + self[2]^2
    return 0 if n == 0
    math.sqrt n

  normalized: =>
    len = @len!
    if len == 0
      Vec2d!
    else
      Vec2d self[1] / len, self[2] / len

  __mul: (other) =>
    if type(other) == "number"
      Vec2d self[1] * other, self[2] * other

  __tostring: =>
    ("vec2d<%d, %d>")\format self[1], self[2]

class Player
  speed: 400
  w: 32
  h: 64
  color: { 237, 139, 5 }

  new: (@x, @y) =>

  update: (dt) =>
    dx = if keyboard.isDown "left" then -1
      elseif keyboard.isDown "right" then 1
      else 0

    dy = if keyboard.isDown "up" then -1
      elseif keyboard.isDown "down" then 1
      else 0

    v = Vec2d(dx, dy)\normalized! * (@speed * dt)

    @x += v[1]
    @y += v[2]

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

