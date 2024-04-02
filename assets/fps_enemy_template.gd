extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var audui_player = $AudioStreamPlayer3D
# var hit_sound = prelad (" hit")
# var dink_sound = prelad ( hit head)
# Get the gravity from the project settings to be synced with RigidBody nodes.
#HEADSHOT ON TAKE DAMAGE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $DamageArea



func is_player_in_sight(player):
	var from_pose = self.global_transform.origin
	var to_pose = player.global_position.origin
	var direction = to_pose - from_pose
	var distance = direction.length
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from_pose
	ray_query.to = from_pose + direction.normalized() * distance
	ray_query.exclude = [get_rid()]
	var result = get_world_3d().direct_space_state.interest_ray(ray_query)
	return result.size != 0 and result.colldier == player


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
