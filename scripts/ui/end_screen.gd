extends CanvasLayer
## Écran de fin de run, réutilisé pour la victoire (boss vaincu) et la défaite.

@onready var title_label: Label = $Panel/TitleLabel
@onready var stats_label: Label = $Panel/StatsLabel
@onready var retry_button: Button = $Panel/RetryButton
@onready var menu_button: Button = $Panel/MenuButton

func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)

func show_result(victory: bool, time_survived: float, level: int, kills: int) -> void:
	visible = true
	get_tree().paused = true
	title_label.text = "VICTOIRE !" if victory else "GAME OVER"
	title_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6) if victory else Color(1.0, 0.4, 0.4))
	var mm: int = int(time_survived) / 60
	var ss: int = int(time_survived) % 60
	stats_label.text = "Temps survécu : %02d:%02d\nNiveau atteint : %d\nEnnemis vaincus : %d" % [mm, ss, level, kills]

func _on_retry() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
