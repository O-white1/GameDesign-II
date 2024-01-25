extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_3_pressed():
	var len = int($Length.text)
	var wid = int($Width.text)
	var area = len * wid
	var perim = 2*len + 2*wid
	$AreaOut.text = str(area)
	$PerimOut.text = str(perim)


func _on_clear_pressed():
	$length.text = ""
	$Width.text = ""
	$AreaOut.text = ""
	$PerimOut.text = ""


func _on_button_2_pressed():
	get_tree().quit()
