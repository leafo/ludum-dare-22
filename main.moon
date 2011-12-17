
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

class World
  gravity: 0.5
  new: (@vx=0, @vy=0)=>
    @map = Map.from_image "images/map1.png"

  show_collidable: =>
    for box in *@map\get_candidates @player.box
      box\draw { 240, 81, 90 }

  collides: (thing) =>
    for tile_box in *@map\get_candidates thing.box
      return true if thing.box\touches_box tile_box
    false

  draw: =>
    @map\draw!
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
    @world.player = self

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
    @player = Player @w, 100, 100

  update: (dt) =>
    @player\update dt
    @dt = dt

  draw: =>
    @player\draw!
    @w\draw!
    setColor {255,255,255}
    if @dt
      graphics.print tostring(math.floor(1.0/@dt)), 10, 10

    graphics.print tostring(@player.velocity), 10, 20
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

