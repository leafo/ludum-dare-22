
-- theme: alone
-- moonscript idea: hello\box!\world can be written as hello\box\world

require "moon"

import p from moon
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love
import insert from table

export game

scale = 2
screen = {
  scale: scale
  w: 800/scale
  h: 400/scale
}

_newImage = graphics.newImage
graphics.newImage = (...) ->
  print "loading image"
  with _newImage ...
    \setFilter "nearest", "nearest"

export imgfy = (img) ->
  img = graphics.newImage img if "string" == type img
  img

export smoothstep = (t) -> t*t*(3 - 2*t)

require "collide"
require "map"
require "spriter"
require "particle"
require "player"
require "background"

class Viewport
  new: =>
    @box = Box 0,0, screen.w, screen.h

  apply: =>
    graphics.translate -@box.x, -@box.y

  unproject: (x,y) =>
    x, y = x / screen.scale, y / screen.scale
    @box.x + x, @box.y + y

  center_on: (thing) =>
    cx, cy = thing.box\center!

    @box.x = cx - @box.w / 2
    @box.y = cy - @box.h / 2


    @box.x = 0 if @box.x < 0
    @box.y = 0 if @box.y < 0

    max_x = game.w.map.real_width - @box.w
    max_y = game.w.map.real_height - @box.h

    @box.x = max_x if @box.x > max_x
    @box.y = max_y if @box.y > max_y


class World
  gravity: 0.5
  new: (@vx=0, @vy=0)=>
    @bgs = {
      Paralax "images/bg1.png", 0.5
      Paralax "images/bg2.png", 0.8, 0.9, {
        repeat_y: false
        oy: 1210
      }
    }
    @map = Map.from_image "images/map1.png", "images/tiles.png"

    @overlay = (y) ->
      p = y / @map.real_height
      if p > 0.5
        a = smoothstep (p - 0.5) * 2
        a = math.floor a * 255
        setColor 255,255,255,a
        @map.sprite\draw_sized 8, 0,0, screen.w, screen.h

  spawn_player: (@player) =>
    if @map.spawn
      @player.box\set_pos unpack @map.spawn

  show_collidable: =>
    for box in *@map\get_candidates @player.box
      Box.draw box, { 240, 81, 90, 128 }

  collides: (thing) =>
    for tile_box in *@map\get_candidates thing.box
      return true if thing.box\touches_box tile_box
    false

  draw: =>
    for bg in *@bgs
      bg\draw game.viewport

    @map\draw game.viewport
    @player\draw! if @player
    -- @show_collidable!

bb = 0

class Game
  new: =>
    @w = World!
    @viewport = Viewport!
    @player = Player @w, 100, 100

    @w\spawn_player @player

    @emitters = {}

  update: (dt) =>
    @player\update dt

    for e in *@emitters
      e\update dt

  draw: =>
    graphics.scale screen.scale, screen.scale
    graphics.push!
    @viewport\center_on @player
    @viewport\apply!
    @w\draw!

    for e in *@emitters
      e\draw!

    graphics.pop!

    @w.overlay @player.box.y

    setColor {255,255,255}

    graphics.print tostring(love.timer.getFPS!), 10, 10
    graphics.print tostring(@player.box), 10, 20
    graphics.print tostring(@player), 10, 30

  keypressed: (key, code) =>
    if key == "lctrl"
      game.player\shoot!

    if key == "n"
      bb += 1
      print "bb:", bb

    os.exit! if key == "escape"

  mousepressed: (x, y, button) =>
    if button == "l"
      x, y = @viewport\unproject x,y
      insert @emitters, Emitter x, y
    else
      @emitters = {}
    nil


love.load = ->
  g = Game!
  love.update = g\update
  love.draw = g\draw
  love.keypressed = g\keypressed
  love.mousepressed = g\mousepressed

  game = g
  -- love.keyreleased = g\keyreleased

