extends CharacterBody2D
class_name EnemyBase
## Base commune à tous les ennemis : poursuite du joueur, PV, dégâts au contact,
## réaction au knockback/pull et au ralentissement. Les ennemis concrets
## surchargent _steer() pour un comportement différent (mêlée, distance, boss).

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_flash_color: Color = Color(1, 1, 1)

var max_hp: float = 20.0
var current_hp: float = 20.0
var move_speed: float = 90.0
var contact_damage: float = 8.0
var xp_value: int = 2
var contact_tick_interval: float = 0.5

var external_velocity: Vector2 = Vector2.ZERO
const EXTERNAL_DECAY: float = 500.0

var slow_multiplier: float = 1.0
var _slow_timer: float = 0.0

var player_ref: Node2D = null
var _contact_tick_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("enemy_contact")
	collision_layer = 1 << 1  # enemies
	collision_mask = 1 << 1   # se bloquent légèrement entre eux + le sol logique
	current_hp = max_hp
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			slow_multiplier = 1.0

	var steer: Vector2 = _steer(delta)
	velocity = steer * move_speed * slow_multiplier + external_velocity
	move_and_slide()

	external_velocity = external_velocity.move_toward(Vector2.ZERO, EXTERNAL_DECAY * delta)

	if velocity.length() > 5.0:
		sprite.rotation = velocity.angle() + PI / 2.0

func _steer(_delta: float) -> Vector2:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
	if player_ref and is_instance_valid(player_ref):
		return (player_ref.global_position - global_position).normalized()
	return Vector2.ZERO

func get_contact_damage() -> float:
	return contact_damage

func take_damage(amount: float) -> void:
	current_hp -= amount
	_flash()
	if current_hp <= 0.0:
		die()

func apply_knockback(force: Vector2) -> void:
	external_velocity += force

func apply_pull(force: Vector2) -> void:
	external_velocity += force

func apply_slow(amount: float, duration: float) -> void:
	slow_multiplier = min(slow_multiplier, 1.0 - amount)
	_slow_timer = max(_slow_timer, duration)

func _flash() -> void:
	sprite.modulate = Color(2.2, 2.2, 2.2)
	var t := get_tree().create_timer(0.08)
	t.timeout.connect(func(): if is_instance_valid(sprite): sprite.modulate = hit_flash_color)

func die() -> void:
	EventBus.enemy_died.emit(self, xp_value, global_position)
	queue_free()
