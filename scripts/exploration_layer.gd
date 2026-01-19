extends TileMapLayer
class_name ExplorationLayer

var explored := {}

func hide_all():
    for cell in get_used_cells():
        explored[cell] = false
        set_cell(cell, 0) # 0: Black tile in your tileset

func reveal(tile: Vector2i):
    if explored.get(tile, false):
        return
    explored[tile] = true
    #set_cell(tile, -1) # remove black tile
    print("Erasing cell %s" % tile)
    self.erase_cell(tile)
