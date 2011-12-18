
require "moon"
import mixin_object, p from moon
import graphics from love
import rectangle, setColor, getColor from love.graphics

export *

class Repeater
  new: (@rate, @action) => @time = 0

  update: (dt, ...) =>
    @time += dt
    while @time > @rate
      @time -= @rate
      self.action ...
    true

class EnemySpawn
  new: (@o, rate) =>
    print "new spawner"
    @repeater = Repeater rate, self\spawn
    mixin_object self, @repeater, { "update" }

  spawn: (world) =>
    if not @added
      @added = true
      world\add Enemy world, @o.x, @o.y

  draw: =>
    setColor {255, 0, 0}
    rectangle "fill", @o.x, @o.y, 2,2

class Enemy extends Entity
  draw: =>
    @box\draw {255, @immune and 255 or 100, 187}

  update: (dt, world) =>
    super dt, world

    if @immune
      @immune -= dt
      if @immune < 0
        @immune = nil

    -- if @on_ground
    --   print "I AM ON GROUND"

    true


