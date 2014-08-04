#!/usr/bin/env bundle exec ruby

require 'colorize'

class InvalidInput < Exception
end

class OutOfBounds < Exception
end

class Simulator
  attr_accessor :rovers, :x_max, :y_max

  def initialize file_name=""
    raise InvalidInput unless File.exist? file_name
    file = File.read file_name
    lines = file.split("\n")
    raise InvalidInput if lines.length % 2 == 0 or lines.length == 1
    (@x_max, @y_max) = lines[0].split(' ').map(&:to_i)
    create_rovers lines.select.each_with_index { |str, i| i.odd? }
    rovers.map{ |rover| rover.enforce_boundary(x_max, y_max) }
  end

  private

    def create_rovers lines
      @rovers = []
      lines.each do |line|
        rovers << Rover.new(*line.split(' '))
      end
    end

end

class Rover
  attr_accessor :x_position, :y_position, :orientation

  def initialize x_position, y_position, orientation
    @x_position = x_position.to_i
    @y_position = y_position.to_i
    @orientation = orientation
    @compass = { "N" => {"L" => "W", "R" => "E", "X" => 0, "Y" => 1},
                 "E" => {"L" => "N", "R" => "S", "X" => 1, "Y" => 0},
                 "W" => {"L" => "S", "R" => "N", "X" => -1, "Y" => 1},
                 "S" => {"L" => "E", "R" => "W", "X" => 0, "Y" => -1} }
  end

  def enforce_boundary x_boundary, y_boundary
    raise OutOfBounds if @x_position > x_boundary or @y_position > y_boundary
    raise OutOfBounds if @x_position < 0 or @y_position < 0
  end

  def move movement
    case movement
    when "M"
      @x_position += @compass[orientation]["X"]
      @y_position += @compass[orientation]["Y"]
    else
      @orientation = @compass[orientation][movement]
    end
  end
end

if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd
  puts Simulator.new(ARGV[0])
end
