extends Node3D



func _ready():
	pass



func _process(delta):
	pass


func _on_race_body_entered(body):
		get_tree().change_scene_to_file("res://rc_world.tscn")
