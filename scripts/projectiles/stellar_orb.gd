extends "res://scripts/projectiles/projectile_base.gd"
## Orbe stellaire (Lyra) : au contact d'un ennemi, inflige des dégâts puis
## bondit vers l'ennemi valide le plus proche non déjà touché.

var bounce_left: int = 2
const BOUNCE_RANGE: float = 420.0

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemy"):
		return
	if hit_enemies.has(body):
		return
	hit_enemies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(damage)

	if bounce_left <= 0:
		queue_free()
		return
	bounce_left -= 1

	var next_target: Node2D = _find_next_bounce_target()
	if next_target == null:
		queue_free()
		return
	direction = (next_target.global_position - global_position).normalized()
	rotation = direction.angle()
	homing_target = next_target
	homing_strength = 8.0

func _find_next_bounce_target() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemy")
	var best: Node2D = null
	var best_dist := BOUNCE_RANGE
	for e: Node2D in enemies:
		if not is_instance_valid(e) or hit_enemies.has(e):
			continue
		var d: float = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best
