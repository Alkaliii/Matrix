extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_mouse_entered():
	get_tree().create_tween().tween_property(self,"modulate",Color.ORANGE_RED,0.15).set_ease(Tween.EASE_IN_OUT)


func _on_mouse_exited():
	get_tree().create_tween().tween_property(self,"modulate",Color.WHITE,0.15).set_ease(Tween.EASE_IN_OUT)


func _on_pressed():
	Gsb.close_matrix.emit()
