
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
require "map"

center_on = (thing) ->
  graphics.translate -thing.box.x, -thing.box.y

class Viewport
  new: =>
    @box = Box 0,0, screen.w, screen.h

  apply: =>
    graphics.translate -@box.x, -@box.y

  center_on: (thing) =>
    cx, cy = thing.box\center!

    @box.x = cx - @box.w / 2
    @box.y = cy - @box.h / 2

class World
  gravity: 0.5
  new: (@vx=0, @vy=0)=>
    @map = Map.from_image "images/map1.png"

  spawn_player: (@player) =>
    if @map.spawn
      @player.box\set_pos unpack @map.spawn

  show_collidable: =>
    for box in *@map\get_candidates @player.box
      box\draw { 240, 81, 90 }

  collides: (thing) =>
    for tile_box in *@map\get_candidates thing.box
      return true if thing.box\touches_box tile_box
    false

  draw: (viewport) =>
    @map\draw viewport
    @player\draw! if @player
    @show_collidable!

class Player
  gravity: Vec2d 0, 20
  speed: 400
  w: 16
  h: 32
  color: { 237, 139, 5 }

  __tostring: =>
    ("player<grounded: %s>")\format tostring @on_ground

  new: (@world, x=0, y=0) =>
    @box = Box x, y, @w, @h
    @velocity = Vec2d 0, 0

    @on_ground = false

  update: (dt) =>
    dx = if keyboard.isDown "left" then -1
      elseif keyboard.isDown "right" then 1
      else 0
  
    if @on_ground and keyboard.isDown " "
      @velocity[2] = -400
    else
      @velocity += @gravity

    delta = Vec2d dx*@speed, 0
    delta += @velocity

    delta *= dt
    collided = @fit_move unpack delta
    if collided
      @velocity[2] = 0
      if delta.y > 0
        @on_ground = true
    else
      if math.floor(delta.y) != 0
        @on_ground = false

  -- returns true if there was a y axis collision
  fit_move: (dx, dy) =>
    collided = false
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
        collided = true
        @box.y -= ddy

    collided

  draw: =>
    @box\draw @color

b = Box 0,0, 100, 100

class Game
  new: =>
    @w = World!
    @view = Viewport!
    @player = Player @w, 100, 100

    @w\spawn_player @player

  update: (dt) =>
    @player\update dt
    @dt = dt

  draw: =>
    graphics.push!
    @view\center_on @player
    @view\apply!
    @w\draw @view
    graphics.pop!

    setColor {255,255,255}

    graphics.print tostring(love.timer.getFPS!), 10, 10
    graphics.print tostring(@player.box), 10, 20
    graphics.print tostring(@player), 10, 30

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

