extends Control

@onready var intro = $kbb/VBoxContainer/ScrollContainer/VBoxContainer/Intro
@onready var h_2m = $kbb/VBoxContainer/ScrollContainer/VBoxContainer/H2M
@onready var export = $kbb/VBoxContainer/ScrollContainer/VBoxContainer/Export
@onready var reference = $kbb/VBoxContainer/ScrollContainer/VBoxContainer/Reference
@onready var splash_2 = $kbb/Splash2
@onready var progress_bar = $kbb/Splash2/ProgressBar

const cw = preload("res://creditswindow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Gsb.help_ui.connect(open_close)
	open_close("OPEN")

func open_close(state):
	var TWEE = get_tree().create_tween()
	match state:
		"OPEN":
			TWEE.tween_property(self,"position:x",0,0.35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		"CLOSE":
			TWEE.tween_property(self,"position:x",1280,0.35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func hide_all():
	intro.hide()
	h_2m.hide()
	export.hide()
	reference.hide()

func show_creds():
	var new = cw.instantiate()
	add_child(new)
	return
	
	#progress_bar.value = 0
	#var TWEE = get_tree().create_tween()
	#TWEE.tween_property(splash_2,"scale",Vector2.ONE,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#TWEE.tween_property(progress_bar,"value",100,5).set_ease(Tween.EASE_IN_OUT)
	#TWEE.tween_property(splash_2,"scale",Vector2.ZERO,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _on_credits_pressed():
	show_creds()


func _on_reference_pressed():
	hide_all()
	await get_tree().process_frame
	reference.show()


func _on_export_pressed():
	hide_all()
	await get_tree().process_frame
	export.show()


func _on_how_2_pressed():
	hide_all()
	await get_tree().process_frame
	h_2m.show()


func _on_intro_pressed():
	hide_all()
	await get_tree().process_frame
	intro.show()


func _on_close_pressed():
	open_close("CLOSE")
