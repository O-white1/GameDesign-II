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
@onready var rayFL = $RayForwLeft
@onready var rayFR = $RayForwRight
@onready var rayL = $RayLeft
@onready var rayR = $RayRight


func physics_process(delta):
	var target_steering = 0.0
	update_raycasts()
	var acceleration = HORSE_POWER
	if rayF.is_colliding():
		var dist_to_obstacle = rayF.get_collision_point().distance_to(global_transform.origin)
		acceleration *= max(0.1, dist_to_obstacle / 10.0)
		if rayFL.is_colliding or rayL.is_colliding(): target_steering -= MAX_STEER
		if rayFR.is_colliding: target_steering += MAX_STEER
		if is_stuck: acceleration = REVERSE_POWER
		steering = -sin(steering) * MAX_STEER
		
		$backLeft.engine_force = calc_engine_force(acceleration, abs($backLeft.get_rpm()))
		$backRight.engine_force = calc_engine_force(acceleration, abs($backRight.get_rpm()))
		check_and_right_vehicle()
		
		
func check_stuck_condition(delta):
	if linear_velocity.length() < 1:
		STUCK_TIMER += delta
	else: STUCK_TIMER = 0
	is_stuck = STUCK_TIMER > STUCK_TIME_THRESHOLD
	
func update_raycasts():
	rayF.force_raycast_update()
	rayFR.force_raycast_update()
	rayFL.force_raycast_update()
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
			
