require 'pry'

def format_for_screen(message)
  message.split("\n").map do |line|
    temp_result = []
    line_array = line.split
    result = []

    loop do
      if temp_result.join(' ').size <= 55 && !line_array.empty?
        temp_result << line_array.shift
        next
      end

      result << temp_result
      temp_result = []
      break if line_array.empty?
    end

    result.map { |section| section.join(' ') }
  end
end

message = """Your first thought was, he lied in every word.
    
    The old man’s malicious eyes stare at you as if he’s bursting inside at the thought of gaining a new victim. He tells a story about a hidden tower, a dark tower, that holds unimaginable power and must be stopped. Yada yada, he goes on and on about an evil being, monsters, many knights have died trying, a quest, and so on.

    Looking at the sun, you notice it’s getting late, so you agree to go the direction he points, grudgingly, but also secretly basking in the grandiose thoughts of high adventure and fame. Mostly, though, you agree because you’re bored and you’re hoping for an end to the boredom … THE end maybe? This will probably end with your death. You need something to do, somewhere to go, someone to be.

    Should you follow his gaze and head out towards the town gates on your quest? Or, maybe it's better to simply go home?"""

puts format_for_screen(message)#.map { |line| line.empty? ? "\n" : line }