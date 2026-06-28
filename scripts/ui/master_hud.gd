extends Control

var huds := {} # name -> node

func _ready() -> void:
    # Scan the children for HUDs and add them to the dictionary
    for child in get_children():
        huds[child.name] = child
        #child.hide()
    #huds.EmptyHUD.show()
        
func hide_all() -> void:
    for hud in huds.values():
        hud.hide()

func show_hud(hud_name: String) -> void:
    hide_all()
    if huds.has(hud_name):
        huds[hud_name].show()
    else:
        print("Error, HUD %s not found" % hud_name)
