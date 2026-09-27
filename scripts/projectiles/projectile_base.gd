extends Area2D
class_name ProjectileBase
## Projectile simple : avance en ligne droite (ou légèrement homing), inflige des
## dégâts au premier contact, peut perforer plusieurs ennemis (pierce), disparaît
## après lifetime secondes. Utilisé par Plasma (Nova) et Glace (Comète).

@export var speed: float = 640.0
@export var lifetime: float = 2.2
@export var homing_strength: float = 0.0 # 0 = ligne droite, >0 = tourne vers la cible

var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var pierce_left: int = 0
var hit_enemies: Array = []
var homing_target: Node2D = null
var slow_amount: float = 0.0 # 0..1, ralentit l'ennemi touché (Comète)
var slow_duration: float = 1.2

func _ready() -> void:
	collision_layer = 1 << 2 # player_projectiles
	collision_mask = 1 << 1  # enemies
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(func(): if is_instance_valid(self): queue_free())

func launch(dir: Vector2, dmg: float, extra_pierce: int, extra: Dictionary = {}) -> void:
	direction = dir.normalized()
	damage = dmg
	pierce_left = extra_pierce
	rotation = direction.angle()
	if extra.has("speed"):
		speed = extra["speed"]
	if extra.has("homing_target"):
		homing_target = extra["homing_target"]
		homing_strength = extra.get("homing_strength", 3.0)
	if extra.has("slow_amount"):
		slow_amount = extra["slow_amount"]
	if extra.has("slow_duration"):
		slow_duration = extra["slow_duration"]

func _physics_process(delta: float) -> void:
	if homing_target and is_instance_valid(homing_target) and homing_strength > 0.0:
		var wanted := (homing_target.global_position - global_position).normalized()
		direction = direction.lerp(wanted, clamp(homing_strength * delta, 0.0, 1.0)).normalized()
		rotation = direction.angle()
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemy"):
		return
	if hit_enemies.has(body):
		return
	hit_enemies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	if slow_amount > 0.0 and body.has_method("apply_slow"):
		body.apply_slow(slow_amount, slow_duration)
	if pierce_left <= 0:
		queue_free()
	else:
		pierce_left -= 1
