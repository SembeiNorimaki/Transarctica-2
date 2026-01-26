extends TileMapLayer
class_name ExplorationLayer

var explored := {}

func hide_all():
	for cell in get_used_cells():
		explored[cell] = false
		set_cell(cell, 0, Vector2i(0,0)) # 0: Black tile in your tileset

func reveal(tiles: Array[Vector2i]):
	hide_all()
	for tile in tiles:
		#if explored.get(tile, false):
		#    return
		explored[tile] = true
		set_cell(tile, 0, Vector2i(1,0)) # remove black tile
		#self.erase_cell(tile)
	queue_redraw()
