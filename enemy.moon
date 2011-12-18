
require "moon"
import mixin_object, p from moon
import graphics from love
import rectangle, setColor, getColor from love.graphics

import abs, random from math

export *

actions = {
  wait: (time) ->
    -- print "waiting", time
    (dt, world) =>
      time -= dt
      time < 0

  jump: (height) ->
    -- print "jumping"
    (dt, world) =>
      @velocity[2] = -height
      true

  move_x: (dist, speed) ->
    -- print "moving on x axis", dist, speed
    dx = 0
    (dt, world) =>
      dx += speed * dt
      a = abs dx

      if a > 1
        dist -= a
        cy, cx = @fit_move dx, 0
        dx = 0
        return true if cx

      dist <= 0
}

class Act
  new: (@entity, @get_next) =>
    @current_action = nil

  update: (dt, world) =>
    if not @current_action
      @current_action = self.get_next!

    if @current_action
      finished = self.current_action @entity, dt, world
      if finished
        @current_action = nil

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
  health: 100
  new: (...) =>
    super ...

    @act = Act self, ->
      return false if not @on_ground
      r = random 1,5
      if r > 4
        actions.jump 200
      elseif r > 1
        dir = random! < 0.5 and -1 or 1
        actions.move_x 15, dir * 100
      else
        actions.wait 1

  draw: =>
    @box\draw {255, @immune and 255 or 100, 187}

  update: (dt, world) =>
    super dt, world

    if @immune
      @immune -= dt
      if @immune < 0
        @immune = nil

    @act\update dt, world
    true


