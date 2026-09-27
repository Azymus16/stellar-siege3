extends Control
## Menu principal : génère dynamiquement une carte par personnage (sprite,
## nom, description) et lance la partie avec le personnage sélectionné.

@onready var characters_container: HBoxContainer = $VBox/CharactersContainer
@onready var play_button: Button = $VBox/PlayButton

var selected_id: String = "nova"
var _group := ButtonGroup.new()

func _ready() -> void:
	for data in CharacterDatabase.get_ordered_list():
		_add_character_card(data)
	play_button.pressed.connect(_on_play_pressed)

func _add_character_card(data: CharacterData) -> void:
	var btn := Button.new()
	btn.toggle_mode = true
	btn.button_group = _group
	btn.custom_minimum_size = Vector2(230, 320)
	btn.focus_mode = Control.FOCUS_NONE

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tex := TextureRect.new()
	if ResourceLoader.exists(data.sprite_path):
		tex.texture = load(data.sprite_path)
	tex.custom_minimum_size = Vector2(100, 100)
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var name_label := Label.new()
	name_label.text = data.display_name
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.modulate = data.color
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tag_label := Label.new()
	tag_label.text = data.tagline
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag_label.custom_minimum_size = Vector2(200, 0)
	tag_label.add_theme_font_size_override("font_size", 14)
	tag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(tex)
	vbox.add_child(name_label)
	vbox.add_child(tag_label)
	btn.add_child(vbox)

	btn.pressed.connect(func(): selected_id = data.id)
	characters_container.add_child(btn)

	if data.id == "nova":
		btn.button_pressed = true

func _on_play_pressed() -> void:
	GameManager.start_run(selected_id)
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
