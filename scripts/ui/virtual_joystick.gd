extends Control
## Joystick virtuel : zone tactile fixe en bas à gauche de l'écran.
## N'importe quel toucher commençant dans la moitié gauche de l'écran contrôle
## ce joystick (fonctionne aussi à la souris pour tester dans l'éditeur).

signal moved(vector: Vector2)

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

@export var radius: float = 70.0

var touch_index: int = -2 # -2 = aucun contact ; -1 = souris ; >=0 = doigt
var origin: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_process_input(true)
	call_deferred("_compute_origin")

func _compute_origin() -> void:
	origin = base.global_position + base.size * 0.5
	_update_knob(Vector2.ZERO)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_index == -2 and _is_inside_zone(event.position):
				touch_index = event.index
				_update_from_position(event.position)
		elif event.index == touch_index:
			_release()
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_from_position(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if touch_index == -2 and _is_inside_zone(event.position):
				touch_index = -1
				_update_from_position(event.position)
		elif touch_index == -1:
			_release()
	elif event is InputEventMouseMotion:
		if touch_index == -1:
			_update_from_position(event.position)

func _is_inside_zone(pos: Vector2) -> bool:
	var screen_size: Vector2 = get_viewport_rect().size
	return pos.x < screen_size.x * 0.55

func _update_from_position(pos: Vector2) -> void:
	var delta: Vector2 = pos - origin
	var clamped: Vector2 = delta.limit_length(radius)
	_update_knob(clamped)
	moved.emit(clamped / radius)

func _update_knob(offset: Vector2) -> void:
	knob.position = base.size * 0.5 - knob.size * 0.5 + offset

func _release() -> void:
	touch_index = -2
	_update_knob(Vector2.ZERO)
	moved.emit(Vector2.ZERO)
