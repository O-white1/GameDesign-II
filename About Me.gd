extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	$label.Text = "My name is Owen White.  I am 14 years old.  I am a nerd."


func _on_button_2_pressed():
	$label.Text = ""
