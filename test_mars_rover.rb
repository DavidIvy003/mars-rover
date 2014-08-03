require 'simplecov'
require 'turn/autorun'
require 'colorize'

SimpleCov.start do
  add_filter 'vendor'
end

require './simulator'

describe Simulator do
  it "fails if no input file is given" do
    proc { Simulator.new() }.must_raise InvalidInput
  end

  it "fails if the number of input lines is not odd or <= 3" do
    proc { Simulator.new('invalid_input.txt') }.must_raise InvalidInput
  end

  it "creates one or more rovers" do
    sim = Simulator.new('examples/5_by_5_two_rovers.txt')
    sim.rovers.count.must_equal 2
  end

  it "respects the plateau's upper boundaries" do
    proc { Simulator.new('examples/3_by_3_too_small.txt') }.must_raise OutOfBounds
  end

  it "respects the plateau's lower boundaries" do
    proc { Simulator.new('examples/3_by_3_invalid_start_lower_bounds.txt') }.must_raise OutOfBounds
  end

  it "throws error if rovers colide" do
    sim = Simulator.new('examples/5_by_5_1_1_E.txt')
    proc { sim.deploy_rovers! }.must_raise RoverCollision
  end
end

describe Rover do
  it "knows its own starting position" do
    rover = Rover.new(1, 5, 'E')
    rover.x_position.must_equal 1
    rover.y_position.must_equal 5
    rover.orientation.must_equal 'E'
  end

  it "is able to turn left 360 degrees" do
    rover = Rover.new(5, 6, 'N')
    rover.move('L')
    rover.orientation.must_equal 'W'
    rover.move('L')
    rover.orientation.must_equal 'S'
    rover.move('L')
    rover.orientation.must_equal 'E'
    rover.move('L')
    rover.orientation.must_equal 'N'
  end

  it "it traverses the plateau" do
    rover = Rover.new(1,1, 'E')
    rover.move('M')
    rover.orientation.must_equal 'E'
    rover.x_position.must_equal 2
    rover.y_position.must_equal 1
    rover.move('L')
    rover.orientation.must_equal 'N'
    rover.move('M')
    rover.orientation.must_equal 'N'
    rover.x_position.must_equal 2
    rover.y_position.must_equal 2
  end
end
