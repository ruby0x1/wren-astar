
class AStar {

  static MAX { __max }
  static MAX=(v) { __max=v }

  static path2D(
    start, end,
    cost_get_fn,
    neighbors_get_fn,
    heuristic_fn) {

    var start_id = pair_(start.x, start.y)
    var end_id = pair_(end.x, end.y)
    if(start_id == end_id) return null

    if(!AStar.MAX) AStar.MAX = 250

    var came_from = {}
    var cost_so_far = {}
    var frontier = MinPQ.new {|node| node.priority }

    frontier.add(AStarNode.new(start, 0))
    came_from[start_id] = null
    cost_so_far[start_id] = 0

    var counter = 0
    while(frontier.count > 0) {
      var node = frontier.pop()
      var current = node.value

      node = null
      var current_id = pair_(current.x, current.y)
      if(current_id == end_id) break

      var neighbors = neighbors_get_fn.call(current)
      for(next in neighbors) {
        var new_cost = cost_so_far[current_id] + cost_get_fn.call(current, next)
        var next_id = pair_(next.x, next.y)
        var next_has_cost = cost_so_far.containsKey(next_id)
        if(!next_has_cost || new_cost < cost_so_far[next_id]) {
          cost_so_far[next_id] = new_cost
          var priority = new_cost + heuristic_fn.call(end, next)
          frontier.add(AStarNode.new(next, priority))
          came_from[next_id] = current
        }
      }

      counter = counter + 1
      if(counter == AStar.MAX) return null
    } //while

    var path = []
    var current = end
    var current_id = end_id
    while(current_id != start_id) {
      path.add(current)
      current = came_from[current_id]
      if(!current) return null
      current_id = pair_(current.x, current.y)
    }
    path.add(start)
    return path[-1..0].toList

  } //path2D

  static pair_(x, y) {
    // return IO.pair_16(x, y)
    var x_part = (x & 65535) << 16
    var y_part = y & 65535
    return (x_part | y_part) & 4294967295 //|
  }

} //AStar

class AStarNode {
  value { _value }
  priority { _priority }
  priority=(v) { _priority=v }
  construct new(value, priority) {
    _value = value
    _priority = priority
  }
}

//Min-heap based Priority Queue

class MinPQ {

  value { _array }
  count { _array.count }
  toString { "%(_array)" }

  construct new() {
    _array = []
    _get = Fn.new {|value| value }
  }

  construct new(get_priority_fn) {
    _array = []
    _get = get_priority_fn
  }

  add(value) {
    _array.add(value)
    sift_up(count-1)
  }

  pop() {
    if(count <= 0) return null
    swap(-1, 0)
    var value = _array.removeAt(-1)
    sift_down(0)
    return value
  }

  peek() {
    if(count == 0) return null
    return _array[0]
  }

  sift_up(index) {
    var parent_index = ((index - 1) / 2).floor
    if(parent_index < 0) return // already at root, do nothing

    // If node is > parent, swap (min-heapify)
    var node = _get.call(_array[index])
    var parent = _get.call(_array[parent_index])
    if(node < parent) {
      swap(index, parent_index)
      sift_up(parent_index)
    }
  } //sift_up

  sift_down(index) {
    var child_index = 2 * index + 1
    if(child_index >= count) return // already at bottom, do nothing

    // node has both children, swap with the smaller one (min-heapify)
    if((child_index + 1) < count) {
      var child = _get.call(_array[child_index])
      var other_child = _get.call(_array[child_index + 1])
      if(child > other_child) {
        child_index = child_index + 1
      }
    }

    // If child < node, swap (min-heapify)
    var node = _get.call(_array[index])
    var child = _get.call(_array[child_index])
    if(child < node) {
      swap(child_index, index)
      sift_down(child_index)
    }
  } //sift_down

  swap(a, b) {
    var tmp = _array[a]
    _array[a] = _array[b]
    _array[b] = tmp
  }

} //MinPQ
