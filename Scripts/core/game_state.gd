extends Node
class_name GameState

signal scene_changed(scene_id: String)
signal state_updated

var character := {}
var flags := {}
var history: Array[String] = []
var current_scene_id := ""

func create_character(name: String, player_class_name: String, ancestry: String) -> void:
	var class_data: Dictionary = CampaignData.get_classes().get(player_class_name, {})
	var ancestry_data: Dictionary = CampaignData.get_ancestries().get(ancestry, {})
	var base_attributes := {
		"might": int(class_data.get("might", 0)),
		"agility": int(class_data.get("agility", 0)),
		"presence": int(class_data.get("presence", 0)),
		"insight": int(class_data.get("insight", 0))
	}
	for key: String in ancestry_data.keys():
		base_attributes[key] = int(base_attributes.get(key, 0)) + int(ancestry_data[key])

	character = {
		"name": name,
		"class": player_class_name,
		"ancestry": ancestry,
		"attributes": base_attributes,
		"hp": 12 + int(base_attributes["might"]),
		"stress": 0
	}

	flags.clear()
	history.clear()
	_add_history("%s inicia a campanha como %s %s." % [name, ancestry, player_class_name])
	go_to_scene("tavern_start")

func go_to_scene(scene_id: String) -> void:
	current_scene_id = scene_id
	scene_changed.emit(scene_id)
	state_updated.emit()

func get_current_scene() -> Dictionary:
	return CampaignData.get_scene(current_scene_id)

func is_element_available(element: Dictionary) -> bool:
	if element.has("requires_flags_present"):
		for required_flag: String in element["requires_flags_present"]:
			if not flags.has(required_flag):
				return false
	if element.has("requires_flags_absent"):
		for blocked_flag: String in element["requires_flags_absent"]:
			if flags.has(blocked_flag):
				return false
	return true

func resolve_interaction(element_name: String, interaction: Dictionary) -> String:
	var result_text := str(interaction.get("description", "Ação executada."))

	if interaction.has("dc"):
		var attribute_name := str(interaction.get("attribute", "presence"))
		var modifier := int(character.get("attributes", {}).get(attribute_name, 0))
		var roll := randi_range(1, 20)
		var total := roll + modifier
		var dc := int(interaction["dc"])
		var outcome := "on_success" if total >= dc else "on_failure"
		result_text += "\nTeste: d20(%d) + %s(%d) = %d vs DC %d." % [roll, attribute_name, modifier, total, dc]
		_apply_effects(interaction.get(outcome, {}))
		if interaction.get(outcome, {}).has("log"):
			result_text += "\n" + str(interaction[outcome]["log"])
	else:
		_apply_effects(interaction)

	_add_history("[%s] %s -> %s" % [current_scene_id, element_name, interaction.get("label", "Interagir")])
	_add_history(result_text)
	state_updated.emit()
	return result_text

func _apply_effects(data: Dictionary) -> void:
	for flag_name: String in data.get("set_flags", []):
		flags[flag_name] = true
	if data.has("goto"):
		go_to_scene(str(data["goto"]))

func _add_history(message: String) -> void:
	history.append(message)
