extends Node2D
## Météore (compétence de Nova) : affiche une zone de danger, attend un court
## délai puis inflige des dégâts à tous les ennemis dans le rayon.

@onready var telegraph: Sprite2D = $Telegraph
@onready var impact_sprite: Sprite2D = $MeteorSprite
@onready var explosion: Sprite2D = $Explosion

var damage: float = 20.0
var radius: float = 90.0
var delay: float = 0.75

func setup(target_pos: Vector2, p_damage: float, p_radius: float, p_delay: float = 0.75) -> void:
	global_position = target_pos
	damage = p_damage
	radius = p_radius
	delay = p_delay

func _ready() -> void:
	explosion.visible = false
	impact_sprite.visible = false
	_update_scale()
	var tween := create_tween()
	tween.tween_property(telegraph, "modulate:a", 0.85, delay * 0.5)
	tween.tween_property(telegraph, "modulate:a", 0.3, delay * 0.5)
	get_tree().create_timer(delay).timeout.connect(_impact)

func _update_scale() -> void:
	var base_size: float = 40.0 # rayon de référence du sprite telegraph/explosion (voir SVG)
	var s: float = radius / base_size
	telegraph.scale = Vector2(s, s)
	explosion.scale = Vector2(s, s)

func _impact() -> void:
	telegraph.visible = false
	impact_sprite.visible = false
	explosion.visible = true
	explosion.modulate.a = 1.0
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e: Node2D in enemies:
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) <= radius:
			if e.has_method("take_damage"):
				e.take_damage(damage)
	var tween := create_tween()
	tween.tween_property(explosion, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)
