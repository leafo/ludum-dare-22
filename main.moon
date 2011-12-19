
-- theme: alone
-- moonscript idea: hello\box!\world can be written as hello\box\world

import rectangle, setColor, getColor from love.graphics
import keyboard, graphics, audio from love
import insert from table

export game, screen, button, sounds
export ^

export mixin_object = (object, methods) =>
  for name in *methods
    self[name] = (parent, ...) ->
      object[name](object, ...)


sounds = {}
export play_sound = (name) ->
  s = sounds[name]
  if s
    audio.rewind s
    audio.play s

button = {
  shoot: "c"
  jump: "x"
}

scale = 2
screen = {
  padding: 8
  scale: scale
  w: 800/scale
  h: 400/scale
}

_newImage = graphics.newImage
graphics.newImage = (...) ->
  print "loading image:", ...
  with _newImage ...
    \setFilter "nearest", "nearest"

image_cache = {}
export imgfy = (img) ->
  if "string" == type img
    cached = image_cache[img]
    img = if not cached
      new = graphics.newImage img
      image_cache[img] = new
      new
    else
      cached
  img

export smoothstep = (t) -> t*t*(3 - 2*t)

require "collide"
require "map"
require "spriter"
require "particle"
require "player"
require "background"
require "enemy"
require "ui"

class Viewport
  new: =>
    @box = Box 0,0, screen.w, screen.h

  bigger: =>
    x,y,w,h = @box\unpack!
    Box x - w/2, y - h/2, w*2,h*2

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
  gravity: Vec2d 0, 1000

  add: (item) =>
    if item.type == "enemy"
      @enemies\push item

    @draw_list\add item

  new: =>
    @draw_list = DrawList!
    @enemies = List!

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
      @player.velocity = Vec2d 0, 0

  show_collidable: =>
    for box in *@map\get_candidates @player.box
      Box.draw box, { 240, 81, 90, 128 }

  collides: (thing) =>
    for tile_box in *@map\get_candidates thing.box
      return true if thing.box\touches_box tile_box
    false

  update: (dt) =>
    -- see if we won
    if not game.freeze and @map\is_winning @player
      Victory(game)\attach love
    else
      @draw_list\update dt, self

    -- update enemy spawners
    if @map.spawners
      ss = @map.spawners\get_candidates game.viewport.box
      @visible_spawners = #ss
      for spawn_box in *ss
        spawn_box.spawner\update dt, self

  draw: =>
    for bg in *@bgs
      bg\draw game.viewport

    @map\draw game.viewport
    @player\draw! if @player
    @draw_list\draw!
    -- @show_collidable!

  __tostring: => "world<>"

class Game extends GameState
  flash_duration: 0.1
  freeze: false

  __tostring: => "Game<>"

  new: =>
    game = self
    @start_time = love.timer.getTime!
    @w = World!
    @viewport = Viewport!
    @player = Player @w, 0, 0
    @w\spawn_player @player

    @health_bar = HealthBar!

  flash_screen: (color) =>
    @flash = { :color, time: @flash_duration }

  update: (dt) =>
    return if @paused

    if @flash
      @flash.time -= dt
      @flash = nil if @flash.time < 0

    @health_bar.value = @player.health / @player.max_health

    @w\update dt
    @player\update dt

  draw: =>
    graphics.scale screen.scale, screen.scale
    graphics.push!
    @viewport\center_on @player
    @viewport\apply!
    @w\draw!

    graphics.pop!

    @health_bar\draw!

    @w.overlay @player.box.y

    if @flash
      a = @flash.time / @flash_duration * 128
      r,g,b = unpack @flash.color
      setColor r, g, b, a
      rectangle "fill", 0,0, screen.w, screen.h

    setColor {255,255,255}

    -- graphics.print tostring(love.timer.getFPS!), 10, 10
    -- if @w.visible_spawners
    --   graphics.print ("visible spawners: %d")\format(@w.visible_spawners), 10, 23

  keypressed: (key, code) =>
    if key == button.shoot
      @player\shoot!

    if key == "p"
      @paused = not @paused

    if key == "q"
      print "DIE"
      @player\die!

    os.exit! if key == "escape"

  mousepressed: (x, y, button) =>
    -- x, y = @viewport\unproject x,y
    -- if button == "l"
    --   @w\add EnemySpawn Vec2d(x,y), 0.2

    -- if button == "r"

    --   @w\add with Emitter x, y
    --     .life = 10

    nil

love.load = ->
  source = audio.newSource "sound/theme.ogg"
  source\setLooping true
  source\play!

  sounds.shoot = audio.newSource "sound/shot.wav", "static"
  sounds.hit_wall = audio.newSource "sound/hit_wall.wav", "static"
  sounds.hit_monster = audio.newSource "sound/hit_monster.wav", "static"
  sounds.jump = audio.newSource "sound/jump.wav", "static"
  sounds.start = audio.newSource "sound/start.wav", "static"
  sounds.hit_me = audio.newSource "sound/hit_me.wav", "static"

  game = Menu!
  game\attach love

