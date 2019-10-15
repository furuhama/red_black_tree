# frozen_string_literal: true

BLACK = 0
RED = 1

class Node
  attr_accessor :color, :left, :right, :parent, :key, :value

  def initialize(key, value, color)
    @key = key
    @value = value
    @color = color
  end
end

class Tree
  attr_accessor :root

  def initialize(key, value)
    @root = Node.new(key, value, BLACK)
  end
end
