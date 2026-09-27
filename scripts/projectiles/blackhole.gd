extends Node2D
## Trou noir (compétence d'Orion) : attire tous les ennemis dans son rayon et
## leur inflige des dégâts périodiques pendant sa durée de vie.

@onready var sprite: Sprite2D = $Sprite

var damage_per_tick: float = 6.0
var pull_force: float = 260.0
var radius: float = 260.0
var duration: float = 3.0
var tick_interval: float = 0.5

var _elapsed: float = 0.0
var _tick_accum: float = 0.0
const REF_RADIUS: float = 60.0

func setup(p_tick_damage: float, p_pull: float, p_radius: float, p_duration: float) -> void:
	damage_per_tick = p_tick_damage
	pull_force = p_pull
	radius = p_radius
	duration = p_duration
	var s: float = radius / REF_RADIUS
	sprite.scale = Vector2(s, s)

func _process(delta: float) -> void:
	_elapsed += delta
	rotation += delta * 1.5
	_tick_accum += delta
	var do_tick: bool = false
	if _tick_accum >= tick_interval:
		_tick_accum -= tick_interval
		do_tick = true

	for e: Node2D in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		var to_center: Vector2 = global_position - e.global_position
		var d: float = to_center.length()
		if d <= radius and d > 1.0:
			if e.has_method("apply_pull"):
				e.apply_pull(to_center.normalized() * pull_force * delta)
			if do_tick and e.has_method("take_damage"):
				e.take_damage(damage_per_tick)

	if _elapsed >= duration:
		queue_free()
