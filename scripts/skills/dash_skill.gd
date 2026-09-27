extends "res://scripts/skills/skill_base.gd"
## Éclat de Givre (Comète) : dash rapide qui laisse une traînée de givre dangereuse.

var dash_distance: float = 260.0
var dash_time: float = 0.16
var trail_damage_mult: float = 1.0
var trail_duration_mult: float = 1.0

func activate() -> void:
	var dir: Vector2 = _get_dash_direction()
	player.is_dashing = true
	player.invuln_timer.start(dash_time + 0.2)

	var start_pos: Vector2 = player.global_position
	var end_pos: Vector2 = start_pos + dir * dash_distance

	_spawn_trail_along(start_pos, end_pos)

	var tween := player.create_tween()
	tween.tween_property(player, "global_position", end_pos, dash_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): if is_instance_valid(player): player.is_dashing = false)

func _get_dash_direction() -> Vector2:
	if player.move_input.length() > 0.05:
		return player.move_input.normalized()
	return Vector2.from_angle(player.sprite.rotation - PI / 2.0)

func _spawn_trail_along(start_pos: Vector2, end_pos: Vector2) -> void:
	var segments: int = 4
	var dmg: float = player.get_effective_damage() * 0.4 * trail_damage_mult
	var dur: float = 2.2 * trail_duration_mult
	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		var pos: Vector2 = start_pos.lerp(end_pos, t)
		var scene: PackedScene = load("res://scenes/projectiles/IceTrail.tscn")
		var trail := scene.instantiate()
		player.get_tree().current_scene.add_child(trail)
		trail.global_position = pos
		trail.setup(dmg, 40.0, dur)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"duration_mult":
			trail_duration_mult += value
		"damage_mult":
			trail_damage_mult += value
		_:
			pass
