
require "moon"
import mixin_object, p from moon
import graphics from love
import rectangle, setColor, getColor from love.graphics

import abs, random from math

export *

actions = {
  wait: (time) ->
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
    if @current
      if not @current.alive
        @current = nil
    else
      @current = Slime world, @o.x, @o.y
      world\add @current

  draw: =>
    setColor {255, 0, 0}
    rectangle "fill", @o.x, @o.y, 2,2

class Enemy extends Entity
  type: "enemy"
  health: 100

  onhit: =>
    @hit_time = @flash_duration
    @health -= 44
    return @health < 0

  onremove: =>
    game.w.enemies\remove self

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

    if @health < 0
      return false

    if @immune
      @immune -= dt
      if @immune < 0
        @immune = nil

    @act\update dt, world
    true


class Slime extends Enemy
  new: (...) =>
    super ...

    sprite = Spriter "images/enemy.png", 20, 20, 3
    @a = StateAnim "right", {
      right: sprite\seq {0, 1}, 0.2
      left: sprite\seq {0, 1}, 0.2, true
      right_air: sprite\seq {3}, 0.2
      left_air: sprite\seq {3}, 0.2, true
    }

  update: (dt, world) =>
    state = @facing
    state = state .. "_air" if not @on_ground
    @a\set_state state

    @a\update dt

    super dt, world

  draw: =>
    @set_color!
    @a\draw @box.x, @box.y



