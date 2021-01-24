# frozen_string_literal: true

BLACK = 0
RED = 1
M = Mutex.new

class ID
  @@identification_number = 0

  class << self
    def generate
      M.synchronize do
        @@identification_number += 1
      end
    end
  end
end

class Node
  attr_accessor :color, :left, :right, :parent, :key, :value, :id

  def initialize(key, value, color)
    @id = ID.generate
    @key = key
    @value = value
    @color = color
  end

  def uncle
    parent&.brother
  end

  def ==(node)
    return false unless node

    self.id == node.id
  end

  def dump
    {
      id: id,
      key: key,
      value: value,
      color: color == BLACK ? 'black' : 'red'
    }
  end

  private

  def brother
    return unless parent

    if parent.left == self
      parent.right
    else
      parent.left
    end
  end
end

class Tree
  attr_accessor :root

  def initialize(key, value)
    @root = Node.new(key, value, BLACK)
  end

  def dump
    depth = 1
    node = root

    while node.left
      depth += 1
      node = node.left
    end

    depth_arr = Array.new(depth) { [] }

    depth_arr.each.with_index(1) do |arr, idx|
      if idx == 1
        arr << root
      else
        depth_arr[idx - 2].each do |node|
          arr << node.left if node.left
          arr << node.right if node.right
        end
      end
    end

    depth_arr.each do |arr|
      arr.map!(&:dump).join(', ')
    end.join("\n")
  end

  def insert(key, value)
    node = root
    current = nil

    while node != nil
      current = node
      node = node.key >= key ? node.left : node.right
    end

    node = Node.new(key, value, nil)

    node.parent = current
    if current.key >= key
      current.left = node
    else
      current.right = node
    end

    insertion_fixup(node)

    root.color = BLACK
  end

  def delete(key)
    node = root
    while node != nil && node.key != key
      node = node.key > key ? node.left : node.right
    end

    return if node.nil?

    parent = node.parent
    child = nil

    if node.left && node.right
      succ = find_successor(node)
      node.key = succ.key

      parent = succ.parent
      node = succ
      child = succ.right unless succ.right.nil?
    elsif node.left.nil? && node.right
      child = node.right
    elsif node.left && node.right.nil?
      child = node.left
    end

    if parent
      if parent.left == node
        parent.left = child
      else
        parent.right = child
      end

      child.parent = parent if child
    else
      @root = child
      @root.parent = nil if root
    end

    if node.color == BLACK
      deletion_fixup(child, parent)
    end
  end

  private

  def insertion_fixup(node)
    while node.parent && node.parent.color == RED
      uncle = node.uncle
      parent = node.parent

      if uncle == nil || uncle.color == BLACK
        if parent.parent.left == parent
          if parent.left != node
            left_rotate(parent)
            node = parent
            parent = node.parent
          end

          if parent.left == node
            parent.color = BLACK
            parent.parent.color = RED
            right_rotate(parent.parent)
          end
        else
          if parent.right != node
            right_rotate(parent)
            node = parent
            parent = node.parent
          end

          if parent.right == node
            parent.color = BLACK
            parent.parent.color = RED
            left_rotate(parent.parent)
          end
        end
      elsif uncle && uncle.color == RED
        parent.color = BLACK
        uncle.color = BLACK
        parent.parent.color = RED
        node = parent.parent
      end
    end
  end

  def left_rotate(node)
    right_child = node.right

    rotate(node) do |n|
      n.right = right_child.left
      right_child.left = n
      n.right.parent = n if n.right
      right_child.parent = n.parent
      n.parent = right_child
      right_child
    end
  end

  def right_rotate(node)
    left_child = node.left

    rotate(node) do |n|
      n.left = left_child.right
      left_child.right = n
      n.left.parent = n if n.left
      left_child.parent = n.parent
      n.parent = left_child
      left_child
    end
  end

  def rotate(node)
    parent = node.parent

    yielded_node = yield(node)

    if parent
      if parent.left == node
        parent.left = yielded_node
      else
        parent.right = yielded_node
      end
    else
      self.root = yielded_node
    end
  end
end
