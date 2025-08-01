#defp , is used for a private function
#def,   is used for a public function
#defmodule, is used for defining a module

#Task 1 : Define the expected oven time in minutes ✅
#Task 2 : Calculate the remaining oven time in minutes ✅
#Task 3 : Calculate the preparation time in minutes✅
#Task 4 : Calculate the total working time in minutes✅
#Task 5 : Create a notification that the lasagna is ready

defmodule Lasagna do 
    def expected_minutes_in_oven(), do: 40
    def remaining_minutes_in_oven(x), do:
        Lasagna.expected_minutes_in_oven() - x
    def preparation_time_in_minutes(y), do:
        y * 2
    def total_time_in_minutes(y, a), do:
        preparation_time_in_minutes(y) + a 
    def alarm(), do:
       "Ding!"
end

Lasagna.total_time_in_minutes(3, 20)
Lasagna.alarm()