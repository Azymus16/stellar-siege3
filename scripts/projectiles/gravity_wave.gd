extends Node2D
## Onde gravitationnelle (attaque auto d'Orion) : anneau qui s'étend depuis le
## joueur, endommage et repousse chaque ennemi une seule fois à son passage.

@onready var ring: Sprite2D = $Ring

var damage: float = 8.0
var max_radius: float = 220.0
var duration: float = 0.4
var knockback_force: float = 240.0
var _elapsed: float = 0.0
var _hit: Array = []
const REF_RADIUS: float = 50.0 # rayon de référence du sprite gravity_wave.svg

func setup(p_damage: float, p_radius: float, p_duration: float, p_knockback: float) -> void:
	damage = p_damage
	max_radius = p_radius
	duration = p_duration
	knockback_force = p_knockback

func _process(delta: float) -> void:
	_elapsed += delta
	var ratio: float = clamp(_elapsed / duration, 0.0, 1.0)
	var current_radius: float = max_radius * ratio
	var s: float = current_radius / REF_RADIUS
	ring.scale = Vector2(s, s)
	ring.modulate.a = 1.0 - ratio * 0.8

	for e: Node2D in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e) or _hit.has(e):
			continue
		var d: float = global_position.distance_to(e.global_position)
		if d <= current_radius:
			_hit.append(e)
			if e.has_method("take_damage"):
				e.take_damage(damage)
			if e.has_method("apply_knockback"):
				var dir: Vector2 = (e.global_position - global_position).normalized()
				e.apply_knockback(dir * knockback_force)

	if ratio >= 1.0:
		queue_free()
