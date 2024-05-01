extends Node3D



func _ready():
	pass



func _process(delta):
	pass


func _on_race_body_entered(body):
	var lvl = preload("res://rc_world.tscn").instantiate()
	get_tree().root.add_child(lvl)
