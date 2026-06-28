extends TileMapLayer
class_name ExplorationLayer

# Tile IDs
const VISIBLE_TILE := Vector2i(2, 0)
const EXPLORED_TILE := Vector2i(1, 0)
const UNEXPLORED_TILE := Vector2i(0, 0)

var explored := {} # tile -> bool
var currently_visible := {} # tile -> bool

func hide_all():
    for cell in get_used_cells():
        explored.erase(cell)
        currently_visible.erase(cell)
        set_cell(cell, 0, UNEXPLORED_TILE)

func reveal(visible_tiles: Array):
    #print("Exploration layer: Revealing tiles: ", visible_tiles)
    currently_visible = {}
    
    # mark new visible tiles
    for tile in visible_tiles:
        currently_visible[tile] = true
        explored[tile] = true

    # update tilemap
    _update_tiles()
    queue_redraw()
    # print("Visible tiles: ", visible_tiles.size())
    # print("Explored size: ", explored.size())
    # print("Currently visible size: ", currently_visible.size())

func is_tile_visible(tile: Vector2i) -> bool:
    return currently_visible.has(tile)

func is_tile_explored(tile: Vector2i) -> bool:
    return explored.has(tile)

func _update_tiles():
    for cell in get_used_cells():
        var is_explored_: bool = explored.get(cell, false)
        var is_visible_: bool = currently_visible.get(cell, false)
        
        if not is_explored_:
            set_cell(cell, 0, UNEXPLORED_TILE)
        elif not is_visible_:
            set_cell(cell, 0, EXPLORED_TILE)
        elif is_visible_:
            set_cell(cell, 0, VISIBLE_TILE)
