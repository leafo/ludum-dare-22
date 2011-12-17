
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
    @box = Box.from_pt 0, 300, screen.w, screen.h
    print @box

  collides: (thing) =>
    thing.box\touches_box @box

  draw: =>
    @box\draw { 124, 88, 43 }

class Player
  speed: 400
  w: 32
  h: 64
  color: { 237, 139, 5 }

  new: (@world, x=0, y=0) =>
    @box = Box x, y, @w, @h

  update: (dt) =>
    dx = if keyboard.isDown "left" then -1
      elseif keyboard.isDown "right" then 1
      else 0

    dy = if keyboard.isDown "up" then -1
      elseif keyboard.isDown "down" then 1
      else 0

    v = Vec2d(dx, dy)\normalized! * (@speed * dt)

    @fit_move unpack v

  fit_move: (dx, dy) =>
    dx = math.floor dx
    dy = math.floor dy
    if dx != 0
      ddx = dx < 0 and -1 or 1
      @box.x += dx
      while @world\collides self
        @box.x -= ddx

    if dy != 0
      ddy = dy < 0 and -1 or 1
      @box.y += dy
      while @world\collides self
        @box.y -= ddy

  draw: =>
    @box\draw @color

b = Box 0,0, 100, 100

class Game
  new: =>
    @w = World!
    @player = Player @w, 100, 100

  update: (dt) =>
    @player\update dt

  draw: =>
    @player\draw!
    @w\draw!

  keypressed: (key, code) =>
    os.exit! if key == "escape"

  mousepressed: (x, y, button) =>
    if button == "r"
      print "mouse:", Vec2d x, y
      box = @player.box
      print box\touches_pt x, y
    else
      print @player.box


love.load = ->
  g = Game!
  love.update = g\update
  love.draw = g\draw
  love.keypressed = g\keypressed
  love.mousepressed = g\mousepressed
  -- love.keyreleased = g\keyreleased

