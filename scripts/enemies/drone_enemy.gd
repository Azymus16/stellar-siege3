extends "res://scripts/enemies/enemy_base.gd"
## Foreur (Drone) : garde ses distances et tire des projectiles sur le joueur.

var preferred_distance: float = 340.0
var fire_interval: float = 1.8
var _fire_timer: float = 0.0

func _ready() -> void:
	max_hp = 24.0
	move_speed = 110.0
	contact_damage = 5.0
	xp_value = 3
	super._ready()
	_fire_timer = randf_range(0.2, fire_interval)

func _steer(delta: float) -> Vector2:
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = fire_interval
		_fire_at_player()

	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null or not is_instance_valid(player_ref):
		return Vector2.ZERO
	var to_player: Vector2 = player_ref.global_position - global_position
	var dist: float = to_player.length()
	if dist < preferred_distance - 30.0:
		return -to_player.normalized() # recule
	elif dist > preferred_distance + 30.0:
		return to_player.normalized() # avance
	return Vector2.ZERO # maintient la distance

func _fire_at_player() -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return
	var scene: PackedScene = load("res://scenes/projectiles/EnemyBolt.tscn")
	var b := scene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = global_position
	b.launch((player_ref.global_position - global_position).normalized(), 7.0)
