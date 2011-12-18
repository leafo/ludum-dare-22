
import rectangle, setColor, getColor from love.graphics
import insert from table
import random from math

export *

-- holds a bunch of stuff, and a deadlist
-- item's update returns whether it is still alive
class DrawList
  new: =>
    @dead_list = {}

  add: (item) =>
    dead_len = #@dead_list
    i = if dead_len > 0
      with @dead_list[dead_len]
        @dead_list[dead_len] = nil
    else
      #self + 1

    item.alive = true
    self[i] = item

  update: (dt, ...) =>
    i = 1
    updated = 0
    for item in *self
      if item.alive
        updated += 1
        alive = item\update dt, ...
        if not alive
          item.alive = false
          item\onremove! if item.onremove
          insert @dead_list, i

      i += 1

    updated > 0

  draw: =>
    for item in *self
      item\draw! if item.alive


class Particle
  __tostring: => ("particle<%s>")\format tostring @origin

  new: (@origin, @velocity, @acceleration) =>

  update: (dt) =>
    @origin += @velocity * dt
    @velocity += @acceleration * dt

    box = game.viewport\bigger!
    box\touches_pt unpack @origin

  draw: =>
    rectangle "line", @origin[1], @origin[2], 4, 4

class Emitter extends DrawList
  new: (@x, @y) =>
    super!
    @angle = 60
    @life = -1 -- -1 is forever
    @direction = Vec2d 1, 0
    @accel = Vec2d 0, 0
    @speed = 200
    @rate = 0.1

    @time = 0

  spawn_new: =>
    half = @angle/2
    angle = @direction\angle!
    angle = random angle - half, angle + half
    dir = Vec2d.from_angle(angle) * @speed

    @add Particle Vec2d(@x, @y), dir, @accel

  is_alive: =>
    @life == -1 or @life > 0

  update: (dt, world) =>
    updated = super dt

    -- see if we can spawn new ones
    @time += dt
    while @time > @rate and @is_alive!
      updated = true
      @time -= @rate
      @life -= 1 if @life > 0
      @spawn_new!

    @is_alive! or updated
    

