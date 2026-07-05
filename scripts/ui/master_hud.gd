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

func show_hud(hud_name: String, params: Dictionary = {}) -> void:
    hide_all()
    if huds.has(hud_name):
        var hud = huds[hud_name]
        hud.show()
        if hud.has_method("setup"):
            hud.setup(params)
    else:
        print("Error, HUD %s not found" % hud_name)
