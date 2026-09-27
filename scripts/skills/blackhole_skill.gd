extends "res://scripts/skills/skill_base.gd"
## Trou Noir (Orion) : attire et endommage les ennemis dans une zone pendant un moment.

var duration: float = 3.0
var pull_force: float = 260.0
var radius: float = 260.0

func activate() -> void:
	var dir: Vector2 = player.move_input
	if dir.length() < 0.05:
		dir = Vector2.from_angle(player.sprite.rotation - PI / 2.0)
	var target_pos: Vector2 = player.global_position + dir.normalized() * 260.0

	var scene: PackedScene = load("res://scenes/projectiles/BlackHole.tscn")
	var bh := scene.instantiate()
	player.get_tree().current_scene.add_child(bh)
	bh.global_position = target_pos
	bh.setup(player.get_effective_damage() * 0.55, pull_force, radius, duration)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"duration_mult":
			duration *= (1.0 + value)
		"pull_mult":
			pull_force *= (1.0 + value)
		_:
			pass
