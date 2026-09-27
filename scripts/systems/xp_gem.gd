extends Area2D
## Gemme d'XP lâchée par les ennemis morts. Attirée vers le joueur dès qu'il
## entre dans son rayon de collecte, puis absorbée.

var value: int = 1
var _player: Node2D

func _ready() -> void:
	add_to_group("xp_gem")
	collision_layer = 1 << 4 # pickups
	collision_mask = 0
	_player = get_tree().get_first_node_in_group("player")
	_pulse()

func _pulse() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.4)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.4)

func set_value(v: int) -> void:
	value = v

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var d: float = global_position.distance_to(_player.global_position)
	var radius: float = _player.get_pickup_radius()
	if d <= radius:
		var speed: float = lerp(260.0, 1000.0, clamp(1.0 - d / max(radius, 1.0), 0.0, 1.0))
		global_position += (_player.global_position - global_position).normalized() * speed * delta
		if d < 18.0:
			_player.add_xp(value)
			queue_free()
