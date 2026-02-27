extends Control

@onready var creation_panel: VBoxContainer = %CharacterCreation
@onready var name_input: LineEdit = %NameInput
@onready var class_select: OptionButton = %ClassSelect
@onready var ancestry_select: OptionButton = %AncestrySelect
@onready var start_button: Button = %StartButton

@onready var game_layout: HSplitContainer = %GameLayout
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var scene_title: Label = %SceneTitle
@onready var narrative_label: RichTextLabel = %NarrativeLabel
@onready var history_label: RichTextLabel = %HistoryLabel
@onready var scene_canvas: Control = %SceneCanvas
@onready var interaction_panel: PanelContainer = %InteractionPanel
@onready var interaction_title: Label = %InteractionTitle
@onready var interaction_buttons: VBoxContainer = %InteractionButtons
@onready var feedback_label: RichTextLabel = %FeedbackLabel

var game_state: GameState

func _ready() -> void:
	randomize()
	game_state = GameState.new()
	add_child(game_state)
	game_state.scene_changed.connect(_render_scene)
	game_state.state_updated.connect(_refresh_left_panel)
	_populate_creation_options()
	start_button.pressed.connect(_on_start_pressed)
	creation_panel.visible = true
	game_layout.visible = false
	interaction_panel.visible = false

func _populate_creation_options() -> void:
	for class_name: String in CampaignData.get_classes().keys():
		class_select.add_item(class_name)
	for ancestry_name: String in CampaignData.get_ancestries().keys():
		ancestry_select.add_item(ancestry_name)

func _on_start_pressed() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Aventureiro"
	var selected_class := class_select.get_item_text(class_select.selected)
	var selected_ancestry := ancestry_select.get_item_text(ancestry_select.selected)
	game_state.create_character(player_name, selected_class, selected_ancestry)
	creation_panel.visible = false
	game_layout.visible = true
	_refresh_left_panel()

func _refresh_left_panel() -> void:
	if game_state.character.is_empty():
		return
	var attrs: Dictionary = game_state.character["attributes"]
	character_label.text = "Nome: %s\nClasse: %s\nAncestralidade: %s\nHP: %d\nStress: %d\n\nAtributos\n- Might: %d\n- Agility: %d\n- Presence: %d\n- Insight: %d" % [
		game_state.character["name"],
		game_state.character["class"],
		game_state.character["ancestry"],
		game_state.character["hp"],
		game_state.character["stress"],
		attrs["might"],
		attrs["agility"],
		attrs["presence"],
		attrs["insight"]
	]
	history_label.text = "\n".join(game_state.history.slice(max(game_state.history.size() - 10, 0), game_state.history.size()))

func _render_scene(scene_id: String) -> void:
	for child in scene_canvas.get_children():
		child.queue_free()
	interaction_panel.visible = false
	feedback_label.text = ""

	var scene_data := CampaignData.get_scene(scene_id)
	if scene_data.is_empty():
		scene_title.text = "Cena não encontrada"
		narrative_label.text = ""
		return

	scene_title.text = scene_data.get("title", "")
	narrative_label.text = scene_data.get("narrative", "")

	for element: Dictionary in scene_data.get("elements", []):
		if not game_state.is_element_available(element):
			continue
		var element_button := Button.new()
		element_button.text = str(element.get("name", "Elemento"))
		element_button.custom_minimum_size = Vector2(110, 110)
		element_button.position = element.get("pos", Vector2.ZERO)
		element_button.modulate = element.get("color", Color.WHITE)
		element_button.pressed.connect(func() -> void:
			_open_interactions(element)
		)
		scene_canvas.add_child(element_button)

func _open_interactions(element: Dictionary) -> void:
	interaction_panel.visible = true
	interaction_title.text = "Interações: %s" % element.get("name", "Elemento")
	for child in interaction_buttons.get_children():
		child.queue_free()
	feedback_label.text = ""

	for interaction: Dictionary in element.get("interactions", []):
		var action_button := Button.new()
		action_button.text = str(interaction.get("label", "Interagir"))
		action_button.pressed.connect(func() -> void:
			feedback_label.text = game_state.resolve_interaction(element.get("name", "Elemento"), interaction)
			_refresh_left_panel()
		)
		interaction_buttons.add_child(action_button)
