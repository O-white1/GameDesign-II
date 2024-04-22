extends VehicleBody3D

const MAX_STEER = 0.4
const MAX_RPM = 150
const MAX_TORQUE = 500
const HORSE_POWER = 75
const REVERSE_POWER = -HORSE_POWER*2
const STUCK_TIME_THRESHOLD = 0.5
var STUCK_TIMER = 0
var is_stuck = false

@onready var rayF = $RayForaward
@onready var rayFW = $RayForwLeft
@onready var rayFR = $RayForwRight
@onready var rayL = $RayLeft
@onready var rayR = $RayRight


func physics_process(delta):
	pass	
	
	
	
	
func check_stuck_condition(delta):
	if linear_velocity.length() < 1:
		STUCK_TIMER += delta
	else: STUCK_TIMER = 0
	is_stuck = STUCK_TIMER > STUCK_TIME_THRESHOLD
	
func update_raycasts():
	rayF.force_raycast_update()
	rayFR.force_raycast_update()
	rayFW.force_raycast_update()
	rayL.force_raycast_update()
	rayR.force_raycast_update()


func check_and_right_vehicle():
	if self.global_transform.basis.y.dot(Vector3.UP) < 0:
		var current_rotation = self.rotation_degrees
		current_rotation.x = 0
		current_rotation.z = 0
		self.rotation_degrees = current_rotation

func calc_engine_force(accel, rpm):
	return accel * MAX_TORQUE * (1 - rpm / MAX_RPM)
			
