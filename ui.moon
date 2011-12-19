
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

export *

class HealthBar
  new: =>
    @value = 0.5

    @width = 100
    @height = 8
    @padding = 2

  draw: =>
    import padding, w, h from screen
    setColor 255,255,255

    ox = w - @width - padding
    oy = padding

    rectangle "line",
      ox - @padding, oy - @padding,
      @width + @padding*2, @height + @padding*2

    setColor 227, 52, 52, 200
    rectangle "fill",
      ox, oy, @width * @value, @height


class GameState
  attach: (love) =>
    love.update = self\update
    love.draw = self\draw
    love.keypressed = self\keypressed
    love.mousepressed = self\mousepressed
    -- love.keyreleased = g\keyreleased

  update: =>
  draw: =>
  keypressed: =>
  mousepressed: =>


class FadeOut extends GameState
  timeout: 2.0

  new: (@game) =>
    @game.freeze = true
    @time = @timeout

  update: (dt) =>
    if @time > 0
      @time -= dt
      @game\update dt
    else
      @game = nil
      @real_update dt if @real_update

  draw: =>
    if @time > 0
      setColor 255,255,255, 255
      @game\draw!
      a = 255 * (1 - @time / @timeout)

      setColor 0,0,0, a
      rectangle "fill", 0, 0, screen.w, screen.h
    else
      @real_draw! if @real_draw

class GameOver extends FadeOut
  new: (game) =>
    @time_taken = love.timer.getTime! - game.start_time
    @killed = game.player.enemies_killed
    super game

  keypressed: (key) =>
    Menu!\attach love if key == "return"
    os.exit! if key == "escape"

  real_draw: =>
    setColor 200,200,200, 255
    graphics.print "Game over", 100, 100
    setColor 128, 128, 128
    graphics.print ("Enemies killed: %d")\format(@killed), 100, 120
    graphics.print "Press Enter to go to menu", 100, 180
    setColor 255,255,255

class Victory extends GameOver
  real_draw: =>
    setColor 200,200,200, 255
    graphics.print "You win", 100, 100
    setColor 128, 128, 128
    graphics.print "Thanks for playing!", 100, 120
    graphics.print ("Enemies killed: %d")\format(@killed), 100, 140
    graphics.print ("Time taken: %d seconds")\format(@time_taken), 100, 160

    graphics.print "Press Enter to go to menu", 100, 200
    setColor 255,255,255

class Menu extends GameState
  new: =>
    @title = imgfy "images/title.png"

  draw: =>
    setColor 255,255,255,255
    graphics.scale screen.scale, screen.scale
    graphics.draw @title, 0, 0

    setColor 255,255,255,64
    graphics.print "Arrows to move - X to jump - C to shoot", 10, 185


  update: (dt) =>
    if @game
      print "load time:", dt
      @game\attach love

  keypressed: (key, code) =>
    @game = Game! if key == "return"
    os.exit! if key == "escape"

