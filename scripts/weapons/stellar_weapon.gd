extends "res://scripts/weapons/weapon_base.gd"
## Arme de Lyra : orbes stellaires qui rebondissent d'ennemi en ennemi.

var bounce_count: int = 2

func _ready() -> void:
	base_interval = 0.7

func fire() -> void:
	var target := find_nearest_enemy()
	if target == null:
		return
	var shots: int = 1 + extra_projectiles
	for i in range(shots):
		var t := target
		if i > 0:
			# petite variation d'angle de départ pour les tirs supplémentaires
			pass
		var dir: Vector2 = (t.global_position - player.global_position).normalized()
		if i > 0:
			dir = dir.rotated(deg_to_rad(18.0 * (i if i % 2 == 0 else -i)))
		var scene: PackedScene = load("res://scenes/projectiles/StellarOrb.tscn")
		var proj = scene.instantiate()
		player.get_tree().current_scene.add_child(proj)
		proj.global_position = player.global_position
		proj.bounce_left = bounce_count
		proj.launch(dir, player.get_effective_damage(), 0, {"homing_target": t, "homing_strength": 4.0})

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"extra_bounce":
			bounce_count += int(value)
		_:
			super.apply_upgrade(param_key, value)
