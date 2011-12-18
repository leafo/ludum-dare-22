
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
    for item in *self
      if item.alive
        alive = item\update dt, ...
        if not alive
          item.alive = false
          insert @dead_list, i

      i += 1

  draw: =>
    for item in *self
      item\draw! if item.alive

class Particle
  new: (@origin, @velocity) =>
    @alive = true

  update: (dt) =>
    @origin += @velocity * dt
    @alive = game.viewport.box\touches_pt unpack @origin
    @alive

  draw: =>
    return if not @alive
    rectangle "line", @origin[1], @origin[2], 4, 4

class Emitter extends DrawList
  new: (@x, @y) =>
    super!
    print "created emitter"
    @angle = 60
    @life = 0 -- 0 is forever
    @direction = Vec2d 1, 0
    @speed = 200
    @rate = 0.05

    @time = 0

  spawn_new: =>
    half = @angle/2
    angle = @direction\angle!
    angle = random angle - half, angle + half
    dir = Vec2d.from_angle(angle) * @speed

    @add Particle Vec2d(@x, @y), dir

  update: (dt) =>
    super dt

    -- see if we can spawn new ones
    @time += dt
    if @time > @rate
      @time -= @rate
      @spawn_new!

