extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2(0,720)
	$Ram.position = Vector2(-64,800)
	Gsb.close_matrix.connect(screen_in)

func screen_in():
	var TWEE = get_tree().create_tween()
	TWEE.tween_property(self,"position",Vector2(0,0),0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	TWEE.tween_property($Ram,"position",Vector2(-64,362),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func screen_out():
	var TWEE = get_tree().create_tween()
	TWEE.tween_property($Ram,"position",Vector2(-64,800),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	TWEE.parallel().tween_property(self,"position",Vector2(0,720),0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.15)

func _on_yes_pressed():
	var TWEE = get_tree().create_tween()
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	TWEE.tween_property(get_window(),"size:y",0,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await TWEE.finished
	get_tree().quit()


func _on_no_pressed():
	screen_out()
