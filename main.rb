require './lib/node'
require './lib/tree'

tree = Tree.new((Array.new(15) { rand(1..100) }))
p tree.pretty_print
p tree.level_order
