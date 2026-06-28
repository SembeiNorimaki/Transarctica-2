extends Node2D
class_name NavigationGraphOverlay

var navigation_graph_service: NavigationGraphService
var grid_service: GridService

var node_color := Color(0, 1, 0, 0.6)
var blocked_node_color := Color(1, 0, 0, 0.6)
var edge_color := Color(0, 0.7, 1, 0.4)
var blocked_edge_color := Color(1, 0, 0, 0.8)

func update():
    _draw()
    queue_redraw()

func _draw():
    #var viewport_ref = get_viewport().get_visible_rect()
    #var cam_xform = get_viewport().get_camera().get_transform()
    #var inv = cam_xform.affine_inverse()
    #draw nodes
    for tile in navigation_graph_service.nodes.keys():
        var world_pos = grid_service.tile_to_world(tile)
        #var screen_pos = grid_service.world_to_screen(world_pos)
        if navigation_graph_service.nodes[tile].walkable:
            draw_circle(world_pos, 2, node_color)
        else:
            draw_circle(world_pos, 2, blocked_node_color)
    
    #draw edges
    for edge in navigation_graph_service.edges.values():
        var from_tile = edge.from_tile
        var to_tile = edge.to_tile
        var from_world_pos = grid_service.tile_to_world(from_tile)
        var to_world_pos = grid_service.tile_to_world(to_tile)
        #var from_screen_pos = inv.xform(from_world_pos)
        #var to_screen_pos = inv.xform(to_world_pos)
        draw_line(from_world_pos, to_world_pos, blocked_edge_color)
