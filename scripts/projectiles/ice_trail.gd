extends Node2D
## Traînée de givre (compétence de Comète) : zone posée au sol pendant le dash,
## inflige des dégâts périodiques à tout ennemi qui la traverse.

@onready var sprite: Sprite2D = $Sprite

var damage_per_tick: float = 5.0
var radius: float = 34.0
var duration: float = 2.5
var tick_interval: float = 0.4

var _elapsed: float = 0.0
var _tick_accum: float = 0.0
const REF_RADIUS: float = 32.0

func setup(p_damage: float, p_radius: float, p_duration: float) -> void:
	damage_per_tick = p_damage
	radius = p_radius
	duration = p_duration
	var s: float = radius / REF_RADIUS
	sprite.scale = Vector2(s, s)

func _process(delta: float) -> void:
	_elapsed += delta
	sprite.modulate.a = clamp(1.0 - (_elapsed / duration), 0.0, 1.0)
	_tick_accum += delta
	if _tick_accum >= tick_interval:
		_tick_accum -= tick_interval
		for e: Node2D in get_tree().get_nodes_in_group("enemy"):
			if is_instance_valid(e) and global_position.distance_to(e.global_position) <= radius:
				if e.has_method("take_damage"):
					e.take_damage(damage_per_tick)
				if e.has_method("apply_slow"):
					e.apply_slow(0.4, 0.6)
	if _elapsed >= duration:
		queue_free()
