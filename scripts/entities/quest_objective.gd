class_name QuestObjective
extends RefCounted

var id: String = ""
var type: String = "" # reach_city, deliver_goods, collect_goods, earn_money
var description: String = ""
var target_city: String = ""
var target_resource: String = ""
var target_qty: int = 0
var current_qty: int = 0
var is_completed: bool = false

func update_progress(event_type: String, event_data: Dictionary) -> bool:
	if is_completed:
		return false
		
	var changed = false
	
	match type:
		"reach_city":
			if event_type == "reach_city" and event_data.get("city_name") == target_city:
				current_qty = 1
				is_completed = true
				changed = true
				
		"deliver_goods":
			if event_type == "deliver_goods" and event_data.get("city_name") == target_city and event_data.get("resource_name") == target_resource:
				var add_qty = event_data.get("qty", 0)
				current_qty = clamp(current_qty + add_qty, 0, target_qty)
				is_completed = (current_qty >= target_qty)
				changed = true
				
		"collect_goods":
			if event_type == "collect_goods" and event_data.get("resource_name") == target_resource:
				var new_qty = event_data.get("qty", 0)
				if current_qty != new_qty:
					current_qty = clamp(new_qty, 0, target_qty)
					is_completed = (current_qty >= target_qty)
					changed = true
					
		"earn_money":
			if event_type == "earn_money":
				var money = event_data.get("money", 0)
				if current_qty != money:
					current_qty = clamp(money, 0, target_qty)
					is_completed = (current_qty >= target_qty)
					changed = true
					
	return changed

func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": type,
		"description": description,
		"target_city": target_city,
		"target_resource": target_resource,
		"target_qty": target_qty,
		"current_qty": current_qty,
		"is_completed": is_completed
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", "")
	type = data.get("type", "")
	description = data.get("description", "")
	target_city = data.get("target_city", "")
	target_resource = data.get("target_resource", "")
	target_qty = int(data.get("target_qty", 0))
	current_qty = int(data.get("current_qty", 0))
	is_completed = bool(data.get("is_completed", false))
