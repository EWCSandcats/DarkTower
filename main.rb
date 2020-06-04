# If playing within Repl.it, use the terminal.
# Keyboard shortcut: Ctrl (or Apple) + Shift + S
# Then type `ruby main.rb` and press enter

require 'yaml'
require 'pry'

module Utilities
  def clear_screen
    system('clear') || system('cls')
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

  attr_reader :name, :description, :exits, :adjacent_rooms, :item

  def initialize(name, description, adjacent_rooms, item=nil)
    @name = name
    @description = description
    @adjacent_rooms = adjacent_rooms&.split&.map { |room| room&.gsub('_', ' ')}
    @item = item
  end

  def display_name
    puts "Room: #{name.split('_').map(&:capitalize).join(' ')}\n\n"
  end

  def display_description
    puts format_for_screen(description)
  end

  def display_adjacent_rooms
    room_list = adjacent_rooms&.map { |room| "\"#{room}\"" }&.join(' | ')
    puts "\nAvailable actions: #{room_list}"
  end
end

class Player
  include Utilities

  attr_reader :inventory

  def initialize
    @score = 0
    @inventory = []
  end

  def increment_score
    @score += 1
  end

  def reset_score
    @score = 0
  end

  def add_to_inventory(item)
    @inventory << item
  end

  def display_inventory
    puts "Inventory: #{inventory.join(', ')}"
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
               room.last["adjacent_rooms"],
               room.last["item"])
    end
  end

  def set_current_room(name)
    @current_room = rooms.find { |room| room.name == name.gsub(' ', '_') }
  end

  def check_for_item
    player.add_to_inventory(current_room.item) unless current_room.item == nil
  end

  def play
    loop do
      clear_screen
      current_room.display_name
      current_room.display_description
      
      if ['home', 'lost_adventurers'].include?(current_room.name)
        puts "\nPress enter to continue..."
        break gets
      end

      check_for_item

      current_room.display_adjacent_rooms
      player.display_inventory
      choose_room = player.retrieve_move(current_room.adjacent_rooms)
      set_current_room(choose_room)
    end

    clear_screen
    puts "======="
    puts "THE END"
    puts "=======\n\n"
    puts "Thank you for playing!\n\n"
    puts "This game is based on the poem:"
    puts "'Childe Roland to the Dark Tower Came' by Robert Browning\n\n"
  end
end

MainGame.new
