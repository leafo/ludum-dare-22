
-- theme: alone
-- moonscript idea: hello\box!\world can be written as hello\box\world

require "moon"

import p from moon
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

screen = {
  w: 800
  h: 400
}

require "collide"

class World
  new: (@vx=0, @vy=0)=>
    @box = Box 0, 300, screen.w, screen.h

  collides: (player) =>
    false
    -- player.box = 

  draw: =>
    @box\draw { 124, 88, 43 }

class Player
  speed: 400
  w: 32
  h: 64
  color: { 237, 139, 5 }

  new: (@x, @y) =>

  box: =>
    Box @x, @y, @w, @h

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

b = Box 0,0, 100, 100

class Game
  new: =>
    @player = Player 100, 100
    @w = World!

  update: (dt) =>
    @player\update dt

    -- pb = @player\box!
    -- if b\touches_box pb
    --   print "touching"
    -- else
    --   print "not touching"

  draw: =>
    @player\draw!
    @w\draw!
    -- b\draw { 255,255,255 }

  keypressed: (key, code) =>
    os.exit! if key == "escape"

  mousepressed: (x, y, button) =>
    print "mouse:", Vec2d x, y
    box = @player\box!
    print box
    print box\touches_pt x, y


love.load = ->
  g = Game!
  love.update = g\update
  love.draw = g\draw
  love.keypressed = g\keypressed
  love.mousepressed = g\mousepressed
  -- love.keyreleased = g\keyreleased

