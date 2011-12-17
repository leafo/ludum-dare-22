
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

export *

class Player
  gravity: Vec2d 0, 20
  speed: 300
  w: 14
  h: 30
  color: { 237, 139, 5 }

  __tostring: =>
    ("player<grounded: %s>")\format tostring @on_ground

  new: (@world, x=0, y=0) =>
    @box = Box x, y, @w, @h
    @velocity = Vec2d 0, 0

    @on_ground = false
    @facing = "right"

    sprite = Spriter "images/player.png", 14, 30, 3

    @a = StateAnim "right", {
      right: sprite\seq {0,1,2}, 0.2
      left: sprite\seq {0,1,2}, 0.2, true

      right_air: sprite\seq {3}, 0
      left_air: sprite\seq {3}, 0, true
    }

  update: (dt) =>
    @a\update dt

    dx = if keyboard.isDown "left"
      @facing = "left"
      -1
    elseif keyboard.isDown "right"
      @facing = "right"
      1
    else
      0
  
    if @on_ground and keyboard.isDown " "
      @velocity[2] = -400
    else
      @velocity += @gravity

    delta = Vec2d dx*@speed, 0
    delta += @velocity

    delta *= dt
    collided = @fit_move unpack delta
    if collided
      @velocity[2] = 0
      if delta.y > 0
        @on_ground = true
    else
      if math.floor(delta.y) != 0
        @on_ground = false

    state = @facing
    if not @on_ground
      state = state.."_air"

    @a\set_state state

  -- returns true if there was a y axis collision
  fit_move: (dx, dy) =>
    collided = false
    dx = math.floor dx
    dy = math.floor dy
    if dx != 0
      ddx = dx < 0 and -1 or 1
      @box.x += dx
      while @world\collides self
        @box.x -= ddx

    if dy != 0
      ddy = dy < 0 and -1 or 1
      @box.y += dy
      while @world\collides self
        collided = true
        @box.y -= ddy

    collided

  draw: =>
    -- @box\draw @color
    setColor 255, 255, 255
    @a\draw @box.x, @box.y+1

