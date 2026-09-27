extends "res://scripts/weapons/weapon_base.gd"
## Arme de Comète : éclats de glace qui ralentissent les ennemis touchés.

var slow_amount: float = 0.3

func _ready() -> void:
	base_interval = 0.6

func fire() -> void:
	var target := find_nearest_enemy()
	var base_dir: Vector2 = Vector2.RIGHT.rotated(player.sprite.rotation - PI / 2.0)
	if target:
		base_dir = (target.global_position - player.global_position).normalized()

	var shots: int = 1 + extra_projectiles
	var spread_step: float = 10.0
	var start_angle: float = -spread_step * float(shots - 1) / 2.0
	for i in range(shots):
		var angle_deg: float = start_angle + spread_step * float(i)
		var dir: Vector2 = base_dir.rotated(deg_to_rad(angle_deg))
		var extra := {"slow_amount": slow_amount, "slow_duration": 1.2}
		if target:
			extra["homing_target"] = target
			extra["homing_strength"] = 1.5
		spawn_projectile("res://scenes/projectiles/IceShard.tscn", dir, extra)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"slow_mult":
			slow_amount = min(0.85, slow_amount + value)
		_:
			super.apply_upgrade(param_key, value)
