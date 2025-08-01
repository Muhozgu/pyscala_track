defmodule Rules do
  def eat_ghost?(power_pellet_active?, touching_ghost?) do
    # Please implement the eat_ghost?/2 function
      power_pellet_active? and touching_ghost?    
  end

  def score?(touching_power_pellet?, touching_dot?) do
    # Please implement the score?/2 function
      touching_power_pellet? or touching_dot?
  end

  def lose?(power_pellet_active?, touching_ghost?) do
    # Please implement the lose?/2 function
       not power_pellet_active? and touching_ghost?
  end

  def win?(has_eaten_all_dots?, power_pellet_active?, touching_ghost?) do
    has_eaten_all_dots? and not lose?(power_pellet_active?, touching_ghost?)
  end
end

Rules.eat_ghost?(false, true)
Rules.score?(true, true)
Rules.lose?(false, true)
Rules.win?(false, true, false)

