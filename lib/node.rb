class Node
  include Comparable

  attr_accessor :data, :left, :right

  def <=>(other)
    data <=> other.data
  end

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end
end