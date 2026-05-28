extends CanvasLayer

@onready var quest_list = $Control/VBoxContainer/ScrollContainer/QuestList
@onready var notif_panel = $Notification/NotifPanel
@onready var notif_label = $Notification/NotifPanel/NotifLabel

func _ready() -> void:
	# Check if QuestManager autoload is active
	if has_node("/root/QuestManager"):
		var qm = get_node("/root/QuestManager")
		qm.quests_updated.connect(refresh_ui)
		qm.quest_accepted.connect(_on_quest_accepted)
		qm.quest_completed.connect(_on_quest_completed)
		qm.quest_objective_updated.connect(_on_quest_objective_updated)
	
	refresh_ui()

func refresh_ui() -> void:
	# Clear existing children
	for child in quest_list.get_children():
		child.queue_free()
		
	var active_quests = {}
	var completed_quests = []
	var qm = null
	if has_node("/root/QuestManager"):
		qm = get_node("/root/QuestManager")
		active_quests = qm.active_quests
		completed_quests = qm.completed_quests
		
	if active_quests.is_empty() and completed_quests.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No active quests."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		empty_label.add_theme_font_size_override("font_size", 11)
		quest_list.add_child(empty_label)
		return
		
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		
		# Create quest container
		var quest_container = VBoxContainer.new()
		quest_container.add_theme_constant_override("separation", 4)
		
		# Title label
		var title_label = Label.new()
		title_label.text = quest.title
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if quest.is_main_quest:
			title_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2, 1)) # Gold
		else:
			title_label.add_theme_color_override("font_color", Color(0.3, 0.65, 0.9, 1)) # Cyan
		title_label.add_theme_font_size_override("font_size", 13)
		quest_container.add_child(title_label)
		
		# Description label
		var desc_label = Label.new()
		desc_label.text = quest.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1)) # Grey
		desc_label.add_theme_font_size_override("font_size", 10)
		quest_container.add_child(desc_label)
		
		# Spacing
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 2)
		quest_container.add_child(spacer)
		
		# Objectives
		for obj in quest.objectives:
			var obj_box = HBoxContainer.new()
			obj_box.add_theme_constant_override("separation", 6)
			
			# Checkbox status indicator
			var checkbox_label = Label.new()
			checkbox_label.text = "☑" if obj.is_completed else "☐"
			if obj.is_completed:
				checkbox_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.3, 1)) # Inactive completion green
			else:
				checkbox_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
			checkbox_label.add_theme_font_size_override("font_size", 11)
			obj_box.add_child(checkbox_label)
			
			# Objective description
			var obj_label = Label.new()
			
			# Format progress if numeric
			var progress_str = ""
			if obj.type == "deliver_goods" or obj.type == "collect_goods" or obj.type == "earn_money":
				if not obj.is_completed:
					progress_str = " (%d/%d)" % [obj.current_qty, obj.target_qty]
					
			obj_label.text = obj.description + progress_str
			obj_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			obj_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			if obj.is_completed:
				obj_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 0.8)) # Greenish-grey for done
			else:
				obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1)) # White for active
			obj_label.add_theme_font_size_override("font_size", 10)
			obj_box.add_child(obj_label)
			
			quest_container.add_child(obj_box)
			
		# Add a separator if there are more quests
		var separator = HSeparator.new()
		separator.modulate = Color(1, 1, 1, 0.15)
		quest_container.add_child(separator)
		
		quest_list.add_child(quest_container)
		
	for quest_id in completed_quests:
		if qm == null or not qm.quest_database.has(quest_id):
			continue
			
		var quest_data = qm.quest_database[quest_id]
		var quest_container = VBoxContainer.new()
		quest_container.add_theme_constant_override("separation", 4)
		
		# Title label with tick
		var title_label = Label.new()
		title_label.text = "✓ " + quest_data.get("title", "Untitled Quest")
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 1)) # Greenish for done
		title_label.add_theme_font_size_override("font_size", 13)
		quest_container.add_child(title_label)
		
		# Description label
		var desc_label = Label.new()
		desc_label.text = quest_data.get("description", "")
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1)) # Darker grey
		desc_label.add_theme_font_size_override("font_size", 10)
		quest_container.add_child(desc_label)
		
		var separator = HSeparator.new()
		separator.modulate = Color(1, 1, 1, 0.15)
		quest_container.add_child(separator)
		
		quest_list.add_child(quest_container)
		
	if completed_quests.size() > 0:
		var clear_btn = Button.new()
		clear_btn.text = "Clear Completed"
		clear_btn.add_theme_font_size_override("font_size", 11)
		clear_btn.pressed.connect(_on_clear_completed_pressed)
		quest_list.add_child(clear_btn)

func _on_clear_completed_pressed() -> void:
	if has_node("/root/QuestManager"):
		var qm = get_node("/root/QuestManager")
		qm.completed_quests.clear()
		qm.save_to_game_state()
		refresh_ui()

func show_notification(message: String, is_completion: bool = true) -> void:
	if notif_panel == null or notif_label == null:
		return
		
	notif_label.text = message
	if is_completion:
		notif_panel.color = Color(0.12, 0.45, 0.22, 0.9) # Green for completion
	else:
		notif_panel.color = Color(0.75, 0.55, 0.1, 0.9) # Orange/Gold for accepted
		
	notif_panel.visible = true
	
	# Create fade-in, display, fade-out animation using Tween
	var tween = create_tween()
	notif_panel.modulate.a = 0.0
	tween.tween_property(notif_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(notif_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): notif_panel.visible = false)

func _on_quest_accepted(quest: Quest) -> void:
	show_notification("Accepted Quest:\n" + quest.title, false)
	
	if Assistant:
		var msg = "[b]New Quest: %s[/b]\n%s" % [quest.title, quest.description]
		Assistant.show_message(msg)
		
	refresh_ui()

func _on_quest_completed(quest: Quest) -> void:
	show_notification("Quest Completed:\n" + quest.title, true)
	refresh_ui()

func _on_quest_objective_updated(quest: Quest, objective: QuestObjective) -> void:
	refresh_ui()
