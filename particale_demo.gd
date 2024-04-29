extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer3D.play("res://assets/sounds/engine-loop-1.wav");
	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"): $GPUParticles3D.visisble = not $GPUParticles3D.visibile
