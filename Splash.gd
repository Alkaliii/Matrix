extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_window().size = Vector2(1280,720)
	#get_window().move_to_center()
	#DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)
	var twee = get_tree().create_tween()
	twee.tween_property(self,"position:x",2560,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_delay(1)
	await twee.finished
	queue_free()


#get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
#get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
#get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
#var pos = Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - Vector2(1280,720)*0.5
#twee.tween_property(get_window(),"size:x",1280,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
#twee.parallel().tween_property(get_window(),"size:y",720,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
#twee.parallel().tween_property(get_window(),"position:x",pos.x,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
#twee.parallel().tween_property(get_window(),"position:y",pos.y,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
