class_name Quest
extends RefCounted

var id: String = ""
var title: String = ""
var description: String = ""
var is_main_quest: bool = false
var next_quest: String = ""
var objectives: Array[QuestObjective] = []
var rewards: Dictionary = {}
var status: String = "inactive" # inactive, active, completed

func is_completed() -> bool:
    if objectives.is_empty():
        return false
    for obj in objectives:
        if not obj.is_completed:
            return false
    return true

func update_objectives(event_type: String, event_data: Dictionary) -> bool:
    if status != "active":
        return false
        
    var any_changed = false
    for obj in objectives:
        if obj.update_progress(event_type, event_data):
            any_changed = true
            
    return any_changed

func to_dict() -> Dictionary:
    var objectives_data = []
    for obj in objectives:
        objectives_data.append(obj.to_dict())
        
    return {
        "id": id,
        "title": title,
        "description": description,
        "is_main_quest": is_main_quest,
        "next_quest": next_quest,
        "status": status,
        "rewards": rewards,
        "objectives": objectives_data
    }

func from_dict(data: Dictionary) -> void:
    id = data.get("id", "")
    title = data.get("title", "")
    description = data.get("description", "")
    is_main_quest = bool(data.get("is_main_quest", false))
    next_quest = data.get("next_quest", "")
    status = data.get("status", "inactive")
    rewards = data.get("rewards", {})
    
    objectives.clear()
    var objectives_data = data.get("objectives", [])
    for obj_data in objectives_data:
        var obj = QuestObjective.new()
        obj.from_dict(obj_data)
        objectives.append(obj)
