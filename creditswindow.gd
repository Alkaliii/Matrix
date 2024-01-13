extends Window
@onready var progress_bar = $Splash2/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to_center()
	progress_bar.value = 100
	position += Vector2i(-600,0)
	var TWEE = get_tree().create_tween()
	move()
	TWEE.tween_property($Splash2,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	TWEE.tween_property(progress_bar,"value",0,5).set_ease(Tween.EASE_IN_OUT)
	TWEE.tween_property($Splash2,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
	await TWEE.finished
	queue_free()

func move():
	var TWEE = get_tree().create_tween().set_loops().bind_node(self)
	TWEE.tween_property(get_window(),"position:y",position.y + 30,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_delay(0.2)
	TWEE.tween_property(get_window(),"position:y",position.y,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.2)
