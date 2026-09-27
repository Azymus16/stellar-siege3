extends "res://scripts/enemies/enemy_base.gd"
## Brute : lente et résistante, mais charge périodiquement pour rattraper le joueur.

var charge_interval: float = 3.5
var charge_duration: float = 0.6
var charge_speed_mult: float = 2.6
var _charge_timer: float = 0.0
var _charging: float = 0.0
var _charge_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	max_hp = 70.0
	move_speed = 70.0
	contact_damage = 16.0
	xp_value = 6
	super._ready()
	_charge_timer = randf_range(1.0, charge_interval)

func _steer(delta: float) -> Vector2:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null or not is_instance_valid(player_ref):
		return Vector2.ZERO

	if _charging > 0.0:
		_charging -= delta
		return _charge_dir

	_charge_timer -= delta
	var to_player: Vector2 = (player_ref.global_position - global_position).normalized()
	if _charge_timer <= 0.0:
		_charge_timer = charge_interval
		_charging = charge_duration
		_charge_dir = to_player
		return _charge_dir * charge_speed_mult
	return to_player
