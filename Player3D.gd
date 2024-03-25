extends CharacterBody3D

const WALK_SPEED = 50.0
const RUN_SPEED = 100
var SPEED = WALK_SPEED
const JUMP_VELOCITY = -400

const BOB_FREQ = 2.4
const BOB_AMP = 1
var t_bob = 0

var MAX_HP = 50
var HP = MAX_HP
var dmg_lock = 0.0
var inertia = Vector3.ZERO

var PUSH_FORCE = 25

var dmg_shader = preload("res://assets/Shaders/Take_Damage.tres")
@onready var HUD = get_tree().get_first_node_in_group("HUD")



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const CAM_SENSITIVITY = 0.03
@onready var camera = $head/Camera3D
@onready var camera_arm = $SpringArm3D
@onready var camera_pos = camera.position
var first_person = true

@onready var BASE_FOV = camera.fov #75
var FOV_CHANGE = 1.0


@onready var model = $gobot
@onready var animator = $gobot/AnimationPlayer

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("Sprint"):
		SPEED = RUN_SPEED
		FOV_CHANGE = 2.0
	else:
		SPEED = WALK_SPEED
		FOV_CHANGE = 1.0

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if SPEED == WALK_SPEED:
			animator.play("Walk")
		else:
			animator.play("Run")
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		animator.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("Change_camera"):
		toggle_camera_parent()
	var rot_dir = Input.get_vector("rot_left", "rot_right", "rot_up", "rot_down").normalized()
			
			
	if rot_dir:
		self.rotation.x += rot_dir.x / 100.0
		self.rotation.z += rot_dir.y / 100.0
		
		var velocity_clamped = clamp(velocity.length(), 0.5, SPEED*2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = headbob(t_bob)
		
		
		
	
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if $Feet.overlaps_area(enemy.dmg_area):
			enemy.queue_free()
	
	dmg_lock = max(dmg_lock - delta, 0.0)
	velocity += inertia
	inertia = inertia.move_toward(Vector3(), delta*1000.0)
	
	if dmg_lock == 0:
		HUD.dmg_overlay.material = null
		HUD.healthbar.max_value = MAX_HP
		HUD.healthbar.value = int(HP)
	
	
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		var col = c.get_collider()
		if col is RigidBody3D  and is_on_floor():
			col.apply_central_force(-c.get_normal() * PUSH_FORCE)
	
	if self.global_position.y <= -50:
		take_damage(MAX_HP)
	
	
	
func take_damage(dmg):
	if dmg_lock == 0.0:
		dmg_lock = 0.5
		HP -= dmg
		var dmg_intensity = clamp(1.0 - ((HP + 0.01)/MAX_HP), 0.1, 0.8)
		HUD.dmg_overlay.material = dmg_shader.duplicate()
		HUD.dmg_overlay.material.set_shader_parameter("intensity", dmg_intensity)
		
		
		
	if HP <= 0:
		await get_tree().create_timer(0.25).timeout 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		OS.alert("You Died!")
		get_tree().reload_current_scene()
func headbob(time):
	var pos = Vector3.ZERO
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos
		
		
	
	
func toggle_camera_parent():
	var parent = "head"
	if first_person:
		parent = "SpringArm3D"
		model.visible = true
	var child = camera
	child.get_parent().remove_child(child)
	get_node(parent).add_child(child)
	camera = child
	if not first_person:
		model.visible = false
		camera.position
	first_person = not first_person

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	model.visible = false
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if first_person:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))
