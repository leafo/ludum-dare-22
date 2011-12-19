
import graphics from love
import push, pop, scale, translate from graphics

export *

class StateAnim
  new: (initial, @states) =>
    @current_name = nil
    @set_state initial
    @paused = false

  set_state: (name) =>
    @current = @states[name]
    @current\reset if name != @current_name
    @current_name = name

  update: (dt) =>
    @current\update dt if not @paused

  draw: (x,y) =>
    @current\draw x, y

class Animator
  get_width: => @sprite.cell_w
  get_height: => @sprite.cell_h

  new: (@sprite, @sequence, @rate=0, @flip=false) =>
    @reset!

  reset: =>
    @time = 0
    @i = 1

  update: (dt) =>
    if @rate > 0
      @time += dt
      if @time > @rate
        @time -= @rate
        @i = @i + 1
        @i = 1 if @i > #@sequence

  draw: (x, y) =>
    @sprite\draw_cell @sequence[@i], x, y, @flip

class Spriter
  new: (@img, @cell_w, @cell_h, @width=0) =>
    @img = imgfy @img

    @iw, @ih = @img\getWidth!, @img\getHeight!

    @ox = 0
    @oy = 0

    @quads = {}

  seq: (...) => Animator self, ...

  quad_for: (i) =>
    if not @quads[i]
      sx, sy = if @width == 0
        @ox + i * @cell_w, @oy
      else
        @ox + (i % @width) * @cell_w, @oy + math.floor(i / @width) * @cell_h

      @quads[i] = graphics.newQuad sx, sy, @cell_w, @cell_h, @iw, @ih

    @quads[i]

  draw_sized: (i, x,y, w,h) =>
    q = @quad_for i

    sx = w / @cell_w
    sy = h / @cell_h
    graphics.drawq @img, q, x, y, 0, sx, sy

    nil

  draw_cell: (i, x, y, flip=false) =>
    q = @quad_for i

    if flip
      push!
      translate x, y
      translate @cell_w, 0
      scale -1, 1

      graphics.drawq @img, q, 0, 0

      pop!
    else
      graphics.drawq @img, q, x, y

    nil


