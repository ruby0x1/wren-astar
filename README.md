# wren-astar

A generic implementation of A* pathfinding in the Wren programming language - https://wren.io

Shown below: different hueristics + neighbors + costs

![](images/image0.png)
![](images/image1.png)
![](images/image2.png)

## Usage

The basic usage is `import "astar" for Astar`, and call `Astar.path2D`.
For details about the pathfinding and the things like costs, heuristics and implementation
details, please see https://www.redblobgames.com/pathfinding/a-star/introduction.html

### Requirements
For now, it's required that the nodes you pass to this respond to `.x` and `.y` for the `path2D` function.
That's true for `start`, `end`, and values returned from `neighbors_get_fn`.
Basically, any class is valid, provided it has these getters. An example class is shown below.

```js
class Node {
  x { _x }
  y { _y }
  construct new(x, y) {
    _x = x
    _y = y
  }
}
```

### Astar.path2D

> `start`
A node with an `.x` and `.y` getter that is the beginning of the path

> `end`
A node with an `.x` and `.y` getter that is the goal for the path

> `cost_get_fn` 
A function that returns the traversal cost for a node given to the function.
This function passes a `from` node and a `to` node. if you don't have a cost, return 1.
```js
//no cost?
_cost_get_fn = Fn.new {|from, to| 1 }
//cost from a tilemap, simple (fake) example
_cost_get_fn = Fn.new {|from, to| tiles.get_cost(to.x, to.y) }
```

> `neighbors_get_fn`
A function that returns a list of the neighbors for a given node, as a node with an `.x` and `.y` getter.
This function can decide whether diagonals are included or not.
```js
_neighbors_get_fn = Fn.new {|node|
  var list = []
  //check above, below, left and right.
  if(is_walkable(node.x, node.y+1)) list.add(Node.new(node.x, node.y+1))
  if(is_walkable(node.x, node.y-1)) list.add(Node.new(node.x, node.y-1))
  if(is_walkable(node.x+1, node.y)) list.add(Node.new(node.x+1, node.y))
  if(is_walkable(node.x-1, node.y)) list.add(Node.new(node.x-1, node.y))
  return list
}
```

> `heuristic_fn`
A function that returns a heuristic value for a given point.
```js
_heuristic_fn = Fn.new {|end, point|
  var manhattan = ((end.x - point.x).abs + (end.y - point.y).abs)
  return manhattan * 1.001 //fudge factor, see the linked articles on pathfinding
}
```