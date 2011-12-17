
import rectangle, setColor, getColor from love.graphics
import insert from table
import random from math

export *

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

class Emitter
  new: (@x, @y) =>
    print "created emitter"
    @angle = 60
    @life = 0 -- 0 is forever
    @direction = Vec2d 1, 0
    @speed = 200
    @rate = 0.05

    @time = 0

    @particles = {}
    @dead_list = {}

  spawn_new: =>
    dead_len = #@dead_list
    i = if dead_len > 0
      with @dead_list[dead_len]
        @dead_list[dead_len] = nil
    else
      #@particles + 1

    half = @angle/2
    angle = @direction\angle!
    angle = random angle - half, angle + half

    dir = Vec2d.from_angle(angle) * @speed

    @particles[i] = Particle Vec2d(@x, @y), dir

  update: (dt) =>
    for i, p in ipairs @particles
      alive = p\update dt
      if not alive
        insert @dead_list, i

    -- see if we can spawn new ones
    @time += dt
    if @time > @rate
      @time -= @rate
      @spawn_new!

  draw: =>
    p\draw! for p in *@particles

