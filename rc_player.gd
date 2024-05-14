extends VehicleBody3D
const MAX_STEER = 0.25
const MAX_RPM = 300
const MAX_TORQUE = 200
const HORSE_POWER = 100


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
func calc_engine_force(accel, rpm):
	return accel * MAX_TORQUE * (1 - rpm / MAX_RPM)
func _physics_process(delta):
	steering = lerp(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 5)
	var accel = Input.get_axis("ui_down", "ui_up") * HORSE_POWER
	$backLeft.engine_force = calc_engine_force(accel, abs($backLeft.get_rpm()))
	$backRight.engine_force = calc_engine_force(accel, abs($backRight.get_rpm()))
	
	var fwd_mps = abs((self.linear_velocity * self.transform.basis).z)
	$Label.text = "%d mph" % (fwd_mps * 2.23694) # meteres per second to miles per hour
	
	$CenterMass.global_position = $CenterMass.global_position.lerp(self.global_position, delta*20.0)
	$CenterMass.transform = $CenterMass.transform.interpolate_with(self.transform, delta*5.0)
	$CenterMass/Camera3D.look_at(self.global_position.lerp(self.global_position + self.linear_velocity, delta*5.0))
	var laps = 0
	
	check_and_right_vehicle()
	
func check_and_right_vehicle():
	if Input.is_action_just_pressed("Restart"):
		get_tree().change_scene_to_file("res://level_2_car.tscn")
	if self.global_transform.basis.y.dot(Vector3.UP) < 0:
		var current_rotation = self.rotation_degrees
		current_rotation.x = 0
		current_rotation.z = 0
		self.rotation_degrees = current_rotation
