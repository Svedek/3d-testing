extends CharacterBody3D

signal interact_enter
signal interact_exit

@export var speed:float = 5.0
@export var acceleration:float = 1.0
@export var camera_sens:float = 1.0
@export var interact_range:float = 2.5

@onready var camera:Camera3D = $Camera3D
@onready var interaction_cast:RayCast3D = $InteractionCast

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var interact_active:bool = false

func _ready():
	capture_mouse()

func _physics_process(delta):
	# Update interaction
	interaction_cast.target_position = camera.global_transform.basis * Vector3.FORWARD * interact_range
	if interaction_cast.is_colliding() != interact_active:
		if interaction_cast.is_colliding():
			emit_signal("interact_enter")
			interact_active = true
		else:
			emit_signal("interact_exit")
			interact_active = false
			
	
	var move_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized() * speed * move_dir.length()
	walk_dir.y = velocity.y
	velocity = velocity.move_toward(walk_dir, acceleration * delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

var look_dir:Vector2
func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			release_mouse()
		if event.keycode == KEY_ENTER:
			capture_mouse()
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()

var mouse_captured = false
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
