require './lib/node'
class Tree
  attr_accessor :root

  def initialize(arr)
    @root = build_tree(arr)
  end

  def build_tree(arr)
    return nil if arr.empty?

    arr.sort!.uniq!
    middle = arr.length / 2
    left = arr[0...middle]
    right = arr[middle + 1..]
    Node.new(arr.at(middle), build_tree(left), build_tree(right))
  end

  def insert(data, node = @root)
    new_node = Node.new(data)
    if new_node < node
      if node.left.nil?
        node.left = new_node
      else
        insert(data, node.left)
      end
    elsif new_node > node
      if node.right.nil?
        node.right = new_node
      else
        insert(data, node.right)
      end
    end
  end

  def leftest(node = @root)
    return node if node.left.nil?
    p node.data
    leftest(node.left)
  end

  def rightest(node = @root)
    return node if node.right.nil?

    rightest(node)
  end

  def parent(node, parent = @root)
    return parent if parent.right == node || parent.left == node
    return nil if parent.right.nil? && parent.left.nil?

    if parent > node
      parent(node, parent.left)
    else
      parent(node, parent.right)
    end
  end

  def delete(data, node = @root)
    new_node = Node.new(data)
    case new_node
    when node.left
      if node.left.left.nil? && node.left.right.nil?
        node.left = nil
      elsif node.left.left.nil?
        right = node.left.right
        node.left = right
      elsif node.left.right.nil?
        left = node.left.left
        node.left = left
      else
        leftest = leftest(node.left.right)
        parent(leftest).left = leftest.right
        leftest.left = node.left.left
        leftest.right = node.left.right
        node.left = leftest
      end
    when node.right
      if node.right.left.nil? && node.right.right.nil?
        node.right = nil
      elsif node.right.left.nil?
        right = node.right.right
        node.right = right
      elsif node.right.right.nil?
        left = node.right.left
        node.right = left
      else
        leftest = leftest(node.right.right)
        parent(leftest).left = leftest.right
        leftest.left = node.right.left
        leftest.right = node.right.right
        node.right = leftest
      end
    else
      if new_node < node
        delete(data, node.left)
      else
        delete(data, node.right)
      end
    end
  end

  def find(data, node = @root)
    return node if node.data == data
    return nil if node.left.nil? && node.right.nil?

    if data < node.data
      find(data, node.left)
    else
      find(data, node.right)
    end
  end

  def children(node = @root)
    children = []
    children.push(node.left) unless node.left.nil?
    children.push(node.right) unless node.right.nil?
    children
  end

  def level_order(node = @root, discovered = [])
    discovered.push(node)
    if block_given?
      until discovered.empty?
        n = discovered.shift
        yield(n)
        discovered.push(children(n)).flatten!
      end
    else
      discovered.each do |child|
        discovered.push(children(child)).flatten!
      end
      discovered.map(&:data)
    end
  end

  def level_order_rec(node = root, queue = [], acc = [])
    unless block_given?
      acc << node.data
      queue.push(node.left) unless node.left.nil?
      queue.push(node.right) unless node.right.nil?
      return acc if queue.empty?
      level_order_rec(queue.shift, queue, acc)
    else
      yield(node)
      queue.push(node.left) unless node.left.nil?
      queue.push(node.right) unless node.right.nil?
      return if queue.empty?
      level_order_rec(queue.shift, queue, acc) { |v| yield(v)}
    end
  end

  def inorder(node = root, arr = [])
    unless block_given?
      inorder(node.left, arr) unless node.left.nil?
      arr << node.data
      inorder(node.right, arr) unless node.right.nil?
      arr
    else
      inorder(node.left) { |node| yield(node) } unless node.left.nil?
      yield(node)
      inorder(node.right) { |node| yield(node) } unless node.right.nil?
    end
  end
  
  def preorder(node = root, arr = [])
    unless block_given?
      arr << node.data
      preorder(node.left, arr) unless node.left.nil?
      preorder(node.right, arr) unless node.right.nil?
      arr
    else
      yield(node)
      preorder(node.left) { |node| yield(node) } unless node.left.nil?
      preorder(node.right) { |node| yield(node) } unless node.right.nil?
    end
  end
  
  def postorder(node = root, arr = [])
    unless block_given?
      postorder(node.left, arr) unless node.left.nil?
      postorder(node.right, arr) unless node.right.nil?
      arr << node.data
      arr
    else
      postorder(node.left) { |node| yield(node) } unless node.left.nil?
      postorder(node.right) { |node| yield(node) } unless node.right.nil?
      yield(node)
    end
  end

  def height(node = root, height = 0, acc = [])
    return -1 if node.nil?
    return 0 if node.left.nil? && node.right.nil? && acc.empty? && height.zero?
    return acc << height if node.left.nil? && node.right.nil?

    height += 1
    height(node.left, height, acc) unless node.left.nil?
    height(node.right, height, acc) unless node.right.nil?
    acc.max
  end

  def depth(node = root, comp_node = root, depth = 0)
    return depth if node == comp_node

    depth += 1
    if node < comp_node
      depth(node, comp_node.left, depth)
    else
      depth(node, comp_node.right, depth)
    end
  end

  def balanced?(node = root)
    if ((height(node.left) + 1) - (height(node.right) + 1)).between?(-1, 1)
      return true if node.left.nil? && node.right.nil?

      right = node.right.nil? ? true : balanced?(node.right)
      left = node.left.nil? ? true : balanced?(node.left)
      right && left
    else
      false
    end
  end

  def rebalance
    self.root = Tree.new(self.inorder).root
    self.pretty_print
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end