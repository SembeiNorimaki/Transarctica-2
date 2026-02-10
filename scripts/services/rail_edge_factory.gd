extends Node
class_name RailEdgeFactory

static func create_edge(a: String, b: String, cost: float) -> RailEdge:
    var e := RailEdge.new(a, b, cost)
    return e