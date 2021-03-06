
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

export *

cool_down = 1.0
knock_back = 200

_floor, _ceil = math.floor, math.ceil

floor = (n) ->
  if n < 0
    -_floor -n
  else
    _floor n


ceil = (n) ->
  if n < 0
    -_ceil -n
  else
    _ceil n

class Entity
  flash_duration: 0.1
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
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

    if @hit_time
      @hit_time -= dt
      @hit_time = nil if @hit_time < 0

    true

  loc: => Vec2d @box.x, @box.y

  set_color: =>
    other = if @hit_time
      math.floor 255 * (1 - @hit_time / @flash_duration)
    else
      255
    setColor 255, other, other, 255

  onhit: =>
    @hit_time = @flash_duration

  fit_move: (dx, dy) =>
    collided_x = false
    collided_y = false

    @facing = "right" if dx > 0
    @facing = "left" if dx < 0

    -- x
    if dx > 0
      start = @box.x
      @box.x += dx
      if @world\collides self
        @box.x = floor @box.x
        while @world\collides self
          collided_x = true
          @box.x -= 1
    elseif dx < 0
      start = @box.x
      @box.x += dx
      if @world\collides self
        @box.x = ceil @box.x
        while @world\collides self
          collided_x = true
          @box.x += 1

    -- y
    if dy > 0
      start = @box.y
      @box.y += dy
      if @world\collides self
        @box.y = floor @box.y
        while @world\collides self
          collided_y = true
          @box.y -= 1
    elseif dy < 0
      start = @box.y
      @box.y += dy
      if @world\collides self
        @box.y = ceil @box.y
        while @world\collides self
          collided_y = true
          @box.y += 1

    collided_y, collided_x

class Player extends Entity
  max_health: 100
  enemies_killed: 0

  speed: 200
  bullet_speed: 400
  w: 14
  h: 30
  color: { 237, 139, 5 }

  __tostring: =>
    ("player<grounded: %s>")\format tostring @on_ground

  new: (world, x=0, y=0) =>
    super world, x, y

    @health = @max_health

    @x_knock = 0

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

  die: =>
    @alive = false

    @world\add with Emitter @box\center!
      .direction = Vec2d 0, -1
      .angle = 120
      .rate = 0.05
      .color = {255,255,255}
      .accel = Vec2d 0, 400
      .life = 15

    @world\add with Emitter @box\center!
      .direction = Vec2d 0, -1
      .rate = 0.01
      .accel = Vec2d 0, 800
      .life = 100
      .angle = 180
      .color = {255, 64, 64}
      .fill = "fill"

    GameOver(game)\attach love

  onhit: (enemy) =>
    play_sound "hit_me"
    super enemy
    game\flash_screen {255, 0 ,0}
    @health -= 20
    @health = 0 if @health < 0

    @die!  if @health == 0

  shoot: =>
    play_sound "shoot"
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

    dx = 0 if game.freeze

    if @hit_time
      @hit_time -= dt
      @hit_time = nil if @hit_time < 0

    -- see if we are hitting an enemy
    for e in @world.enemies\each!
      if not e.immune and e.box\touches_box @box
        @onhit e
        e.immune = cool_down
        @velocity[2] = -200
        @x_knock = if @box\left_of e.box
          -knock_back
        else
          knock_back

    if not game.freeze
      if @on_ground and keyboard.isDown button.jump
        play_sound "jump"
        @velocity[2] = -300
      else
        @velocity += @world.gravity * dt

    speed = @speed
    speed /= 1.2 if not @on_ground
    speed /= 1.2 if math.abs(@x_knock) > 30

    delta = Vec2d dx * speed, 0
    delta += @velocity

    -- when a player is hit by enemy
    if @x_knock != 0
      delta[1] += @x_knock
      ax = math.abs(@x_knock)
      if @on_ground
        @x_knock = 0
      if ax < 0.001
        @x_knock = 0
      elseif ax < 10
        @x_knock /= 2
      else
        @x_knock -= 15*dt

    delta[1] = @speed if delta[1] > @speed
    delta[1] = -@speed if delta[1] < -@speed

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
    if @alive != false
      @set_color!
      @a\draw @box.x, @box.y+1

class Bullet
  new: (@world, @anim, o, @v) =>
    @box = Box o.x, o.y, @anim\get_width!, @anim\get_height!

  emitter: =>
    -- find direction
    x, y = @box.x, @box.y
    dx = -1
    if @v\left!
      x += @box.w
      dx = 1

    with Emitter x, y
      .direction = Vec2d dx, 0
      .rate = 0.01
      .accel = Vec2d 0, 800
      .life = 4
      .angle = 80

  update: (dt, world) =>
    @anim\update dt
    @box\move unpack @v * dt

    if world\collides self
      play_sound "hit_wall"
      world\add @emitter!
      false
    else
      -- try all the enemies
      for e in world.enemies\each!
        if e.box\touches_box @box
          play_sound "hit_monster"
          if e\onhit self
            game.player.enemies_killed += 1
            world\add with @emitter!
              .color = {255, 64, 64}
              .fill = "fill"
              .direction = Vec2d 0, -1
          else
            world\add with @emitter!
              .color = {255, 64, 64}
              .fill = "fill"
          return false

      box = game.viewport\bigger!
      box\touches_pt @box.x, @box.y

  draw: =>
    setColor 255, 255, 255, 255
    @anim\draw @box.x, @box.y

  __tostring: =>
    ("bullet<%f, %f>")\format @box.x, @box.y

