
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


class GameOver extends GameState
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

  keypressed: (key) =>
    Menu!\attach love if key == "return"
    os.exit! if key == "escape"

  draw: =>
    if @time > 0
      setColor 255,255,255, 255
      @game\draw!
      a = 255 * (1 - @time / @timeout)

      setColor 0,0,0, a
      rectangle "fill", 0, 0, screen.w, screen.h
    else
      setColor 200,200,200, 255
      graphics.print "Game over", 100, 100
      setColor 128, 128, 128
      graphics.print "Press Enter to go to menu", 100, 120
      setColor 255,255,255

class Menu extends GameState
  new: =>
    @title = imgfy "images/title.png"

  draw: =>
    graphics.scale screen.scale, screen.scale
    graphics.draw @title, 0, 0

  update: (dt) =>
    if @game
      print "load time:", dt
      @game\attach love

  keypressed: (key, code) =>
    @game = Game! if key == "return"
    os.exit! if key == "escape"

