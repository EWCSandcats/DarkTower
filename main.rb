# If playing within Repl.it, use the terminal.
# Keyboard shortcut: Ctrl (or Apple) + Shift + S
# Then type `ruby main.rb` and press enter

require 'yaml'

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
end

class Room
  attr_reader :name, :description, :exits, :adjacent_rooms

  def initialize(name, description, exits, adjacent_rooms)
    @name = name
    @description = description
    @exits = exits
    @adjacent_rooms = adjacent_rooms
  end
end

class Player
  include Utilities

  def initialize
    @name = retrieve_name
    @score = 0
  end

  def to_s
    name.capitalize
  end

  def increment_score
    @score += 1
  end

  def reset_score
    @score = 0
  end

  def retrieve_name
    clear_screen
    puts "What is your name?"

    loop do
      input = gets.chomp
      return input if valid_name?(input)

      puts "Sorry, your name must be 2-15 characters from a-z."
    end
  end

  def valid_name?(input)
    regex = /^[a-z]{2,15}$/i
    input.match?(regex)
  end

  def retrieve_move(exits)
    puts "\nWhat would you like to do?"

    loop do
      input = gets.chomp
      return input if valid_move?(input, exits)

      puts "Sorry, you cannot move in that direction."
    end
  end

  def valid_move?(input, exits)
    exits.include?(input.to_sym)
  end
end

class MainGame
  include Utilities

  attr_reader :player, :rooms, :current_room

  def initialize
    @player = Player.new
    @rooms = load_rooms
    @current_room = set_current_room("start")

    play
  end

  def load_rooms
    room_data = YAML.load_file('rooms.yml')

    room_data.map do |room|
      room_exits = room.last["exits"].split.map(&:to_sym)
      Room.new(room.first,
               room.last["description"],
               room_exits,
               room.last["adjacent_rooms"])
    end
  end

  def set_current_room(name)
    @current_room = rooms.find { |room| room.name == name}
  end

  def play
    loop do
      clear_screen
      puts "Room: #{current_room.name}\n\n"
      puts current_room.description
      puts "\nCurrent exits: #{joinor(current_room.exits)}"
      direction = player.retrieve_move(current_room.exits)
      set_current_room(current_room.adjacent_rooms[direction])
    end
  end
end

MainGame.new