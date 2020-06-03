# If playing within Repl.it, use the terminal.
# Keyboard shortcut: Ctrl (or Apple) + Shift + S
# Then type `ruby main.rb` and press enter

require 'yaml'
require 'pry'

module Utilities
  def clear_screen
    system('clear') || system('cls')
  end

  # :reek:DuplicateMethodCall
  def joinor(array, sep = ', ', word = 'or')
    if array.size >= 3
      "#{array[0..-2].join(sep)}#{sep}#{word}" \
      " #{array.last}"
    elsif array.size == 2
      "#{array.first} #{word} #{array.last}"
    else
      array.first.to_s
    end
  end

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
end

class Room
  include Utilities

  attr_reader :name, :description, :exits, :adjacent_rooms

  def initialize(name, description, adjacent_rooms)
    @name = name
    @description = description
    @adjacent_rooms = adjacent_rooms.split.map { |room| room.gsub('_', ' ')}
  end
end

class Player
  include Utilities

  def initialize
    @score = 0
  end

  def increment_score
    @score += 1
  end

  def reset_score
    @score = 0
  end

  def retrieve_move(adjacent_rooms)
    puts "\nWhere would you like to go?"
    print ">> "

    loop do
      input = gets.chomp
      return input if valid_move?(input, adjacent_rooms)

      puts "Sorry, you cannot move in that direction."
    end
  end

  def valid_move?(input, adjacent_rooms)
    adjacent_rooms.include?(input)
  end
end

class MainGame
  include Utilities

  attr_reader :player, :rooms, :current_room

  def initialize
    @player = Player.new
    @rooms = load_rooms
    @current_room = set_current_room("town_square")

    play
  end

  def load_rooms
    room_data = YAML.load_file('rooms.yml')

    room_data.map do |room|
      Room.new(room.first,
               room.last["description"],
               room.last["adjacent_rooms"])
    end
  end

  def set_current_room(name)
    @current_room = rooms.find { |room| room.name == name.gsub(' ', '_') }
  end

  def play
    loop do
      clear_screen
      puts "Room: #{current_room.name.split('_').map(&:capitalize).join(' ')}\n\n"
      puts format_for_screen(current_room.description)#.map { |line| line.empty? ? "\n" : line }
      room_list = current_room.adjacent_rooms.map do |room|
        "\"#{room}\""
      end
      puts "\nAvailable actions: #{room_list.join(' | ')}"
      direction = player.retrieve_move(current_room.adjacent_rooms)
      set_current_room(direction)
    end
  end
end

MainGame.new
