
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

export *

class Entity
  w: 20
  h: 20

  new: (@world, x, y) =>
    @facing = "right"
    @on_ground = false
    @velocity = Vec2d 0, 0
    @box = Box x, y, @w, @h

  update: (dt) =>
    @velocity += @world.gravity * dt
    collided = @fit_move unpack @velocity * dt

    if collided
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity.y) != 0
        @on_ground = false

    @facing = "left" if @velocity\left!
    @facing = "right" if @velocity\right!
    true

  loc: => Vec2d @box.x, @box.y

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

class Player extends Entity
  speed: 200
  bullet_speed: 400
  w: 14
  h: 30
  color: { 237, 139, 5 }

  __tostring: =>
    ("player<grounded: %s>")\format tostring @on_ground

  new: (world, x=0, y=0) =>
    super world, x, y

    @on_ground = false
    @facing = "right"

    sprite = Spriter "images/player.png", 14, 30, 3

    @a = StateAnim "right", {
      right: sprite\seq {0,1,2}, 0.2
      left: sprite\seq {0,1,2}, 0.2, true

      right_air: sprite\seq {3}, 0
      left_air: sprite\seq {3}, 0, true
    }

    -- bullet
    @bullet_sprite = with Spriter sprite.img, 16, 6, 1
      .ox = 64
      .oy = 0

  shoot: =>
    flip = @facing == "left"

    v = Vec2d @bullet_speed, 0
    v = v * -1 if flip

    pos = @loc! + Vec2d 0, 15

    b = Bullet @world, @bullet_sprite\seq({0,1}, 0.2, flip), pos, v
    @world\add b

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
      @velocity[2] = -300
    else
      @velocity += @world.gravity * dt

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

  draw: =>
    setColor 255, 255, 255
    @a\draw @box.x, @box.y+1

class Bullet
  new: (@world, @anim, o, @v) =>
    @box = Box o.x, o.y, @anim\get_width!, @anim\get_height!

  update: (dt, world) =>
    @anim\update dt
    @box\move unpack @v * dt

    if world\collides self
      -- create emitter
      x, y = @box.x, @box.y

      dx = -1
      if @v\left!
        x += @box.w
        dx = 1

      world\add with Emitter @box.x, @box.y
        .direction = Vec2d dx, 0
        .rate = 0.01
        .accel = Vec2d 0, 800
        .life = 4

      false
    else
      box = game.viewport\bigger!
      box\touches_pt @box.x, @box.y

  draw: =>
    setColor 255, 255, 255, 255
    @anim\draw @box.x, @box.y

  __tostring: =>
    ("bullet<%f, %f>")\format @box.x @box.y

