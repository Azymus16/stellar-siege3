extends Node2D
## Nœud de constellation (compétence de Lyra) : plusieurs nœuds sont placés
## autour du joueur, brillent brièvement puis explosent en chaîne.

@onready var star: Sprite2D = $Star
@onready var explosion: Sprite2D = $Explosion

var damage: float = 14.0
var radius: float = 70.0
var delay: float = 0.5

func setup(target_pos: Vector2, p_damage: float, p_radius: float, p_delay: float) -> void:
	global_position = target_pos
	damage = p_damage
	radius = p_radius
	delay = p_delay

func _ready() -> void:
	explosion.visible = false
	explosion.scale = Vector2(radius / 48.0, radius / 48.0)
	star.scale = Vector2(0.4, 0.4)
	var tween := create_tween()
	tween.tween_property(star, "scale", Vector2(1.3, 1.3), delay * 0.7)
	tween.parallel().tween_property(star, "modulate:a", 1.0, delay * 0.7)
	get_tree().create_timer(delay).timeout.connect(_explode)

func _explode() -> void:
	star.visible = false
	explosion.visible = true
	explosion.modulate.a = 1.0
	for e: Node2D in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) <= radius:
			if e.has_method("take_damage"):
				e.take_damage(damage)
	var tween := create_tween()
	tween.tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
