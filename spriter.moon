
import graphics from love

export *

class StateAnim
  new: (initial, @states) =>
    @current_name = nil
    @set_state initial

  set_state: (name) =>
    @current = @states[name]
    @current\reset if name != @current_name
    @current_name = name

  update: (dt) =>
    @current\update dt

  draw: (x,y) =>
    @current\draw x, y

class Animator
  new: (@sprite, @sequence, @rate) => @reset!

  reset: =>
    @time = 0
    @i = 1

  update: (dt) =>
    @time += dt
    if @time > @rate
      @time -= @rate
      @i = @i + 1
      @i = 1 if @i > #@sequence

  draw: (x, y, ...) =>
    @sprite\draw_cell @sequence[@i], x, y, ...

class Spriter
  new: (@img, @cell_w, @cell_h, @width=0) =>
    @iw, @ih = @img\getWidth!, @img\getHeight!

    @ox = 0
    @oy = 0

    @quads = {}

  seq: (seq, rate) =>
    Animator self, seq, rate

  draw_cell: (i, x, y) =>
    if not @quads[i]
      sx, sy = if @width == 0
        @ox + i * @cell_w, @oy
      else
        @ox + (i % @width) * @cell_w, @oy + math.floor(i / @width) * @cell_h

      @quads[i] = graphics.newQuad sx, sy, @cell_w, @cell_h, @iw, @ih

    graphics.drawq @img, @quads[i], x, y



