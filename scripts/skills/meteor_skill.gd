extends "res://scripts/skills/skill_base.gd"
## Pluie de Météores (Nova) : plusieurs météores tombent autour du joueur.

var meteor_count: int = 4
var meteor_radius: float = 90.0
var spawn_area_radius: float = 380.0

func activate() -> void:
	var dmg: float = player.get_effective_damage() * 1.8
	for i in range(meteor_count):
		var angle: float = randf() * TAU
		var dist: float = randf_range(60.0, spawn_area_radius)
		var target_pos: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * dist
		var delay: float = 0.5 + randf() * 0.5 + float(i) * 0.06
		_spawn_meteor_delayed(target_pos, dmg, delay)

func _spawn_meteor_delayed(target_pos: Vector2, dmg: float, delay: float) -> void:
	var scene: PackedScene = load("res://scenes/projectiles/Meteor.tscn")
	var m := scene.instantiate()
	player.get_tree().current_scene.add_child(m)
	m.setup(target_pos, dmg, meteor_radius, delay)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"extra_meteor":
			meteor_count += int(value)
		"radius_mult":
			meteor_radius *= (1.0 + value)
		_:
			pass
