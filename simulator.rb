#!/usr/bin/env bundle exec ruby

require 'colorize'

class InvalidInput < Exception
end

class OutOfBounds < Exception
end

class RoverCollision < Exception
end

class Simulator
  attr_accessor :rovers, :x_max, :y_max

  def initialize file_name=""
    input_lines = validate_input_file! file_name
    set_max_plateau_dimensions input_lines
    create_rovers parse_nasa_data(input_lines)
    rovers.map{ |rover| rover.enforce_boundary(x_max, y_max) }
  end

  def deploy_rovers!
    rovers.each do |rover|
      rover.instructions.each do |instruction|
        rover.move instruction
        detect_collision! rover
      end
    end
    rover_positions_string
  end

  private

    def detect_collision! rover
      collision = rovers.detect { |r|
                                   r != rover &&
                                   r.x_position == rover.x_position &&
                                   r.y_position == rover.y_position }
      fail RoverCollision, "#{rover.inspect} collided with #{collision.inspect}" if collision
    end

    def set_max_plateau_dimensions lines
      (@x_max, @y_max) = lines[0].split(' ').map(&:to_i)
    end

    def parse_nasa_data input_lines
      [].tap do |data_array|
        input_lines.drop(1).each_slice(2) do |rover_data|
          data_array << [:position, :instructions].zip(rover_data).to_h
        end
      end
    end

    def validate_input_file! file_name
      raise InvalidInput unless File.exist? file_name
      file = File.read file_name
      lines = file.split("\n")
      raise InvalidInput if lines.length % 2 == 0 or lines.length == 1
      lines
    end

    def create_rovers nasa_data
      @rovers = []
      nasa_data.each do |data|
        rovers << Rover.new(*data[:position].split(' '), data[:instructions])
      end
    end

    def rover_positions_string
      output = ""
      rovers.each do |rover|
        output << "#{rover.x_position} #{rover.y_position} #{rover.orientation}\n"
      end
      output
    end
end

class Rover
  attr_accessor :x_position, :y_position, :orientation, :instructions

  def initialize x_position, y_position, orientation, instructions
    @x_position   = x_position.to_i
    @y_position   = y_position.to_i
    @orientation  = orientation
    @instructions = instructions.split(//)
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
