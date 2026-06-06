extends Node
class_name EdgeFactory

enum CoverType {NONE, HALF, FULL}
enum EdgeType {NORMAL, WALL, FENCE, WINDOW, DOOR}


static func create_edge(from_tile: Vector2i, to_tile: Vector2i, kind: int = Edge.EdgeType.NORMAL) -> Edge:
    var e := Edge.new(from_tile, to_tile, kind)

    match kind:
        Edge.EdgeType.NORMAL:
            e.blocks_movement = false
            e.blocks_vision = false
            e.cover_type = Edge.CoverType.NONE

        Edge.EdgeType.WALL:
            e.blocks_movement = true
            e.blocks_vision = true
            e.cover_type = Edge.CoverType.FULL
            e.is_destructible = true
            e.hp = 40

        Edge.EdgeType.FENCE:
            e.blocks_movement = true
            e.blocks_vision = false
            e.cover_type = Edge.CoverType.HALF
            e.is_destructible = true
            e.hp = 20

        Edge.EdgeType.WINDOW:
            e.blocks_movement = true
            e.blocks_vision = false
            e.cover_type = Edge.CoverType.FULL
            e.is_destructible = true
            e.hp = 15

        Edge.EdgeType.DOOR:
            e.blocks_movement = true
            e.blocks_vision = true
            e.cover_type = Edge.CoverType.FULL
            e.is_destructible = true
            e.hp = 25

    return e
