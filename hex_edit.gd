extends Control


var ca = false
var adju = ""
var cf = 0
var cfs = 7.2

# Called when the node enters the scene tree for the first time.
func _ready():
	Gsb.hex_ui.connect(open_close)
	_on_ca_select_pressed()
	open_close("CLOSE")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open_close(state):
	ca = $PreviewBack/Control/VBoxContainer/ca_ask/ca_select.button_pressed
	adju = $PreviewBack/Control/VBoxContainer/Adjustments.text
	cf = $PreviewBack/Control/VBoxContainer/c_screen_font/font_select.selected
	cfs = $PreviewBack/Control/VBoxContainer/c_font_size/size_select.value
	var TWEE = get_tree().create_tween()
	match state:
		"OPEN":
			TWEE.tween_property(self,"position:x",0,0.35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		"CLOSE":
			TWEE.tween_property(self,"position:x",-1280,0.35).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_close_pressed():
	match Gsb.hex:
		true:
			Gsb.hex_ui.emit("CLOSE")
		false:
			Gsb.hex_ui.emit("OPEN")
	Gsb.hex = !Gsb.hex


func _on_ca_select_pressed():
	var val = $PreviewBack/Control/VBoxContainer/ca_ask/ca_select.button_pressed
	$PreviewBack/Control/VBoxContainer/Adjustments.visible = val
	$PreviewBack/Control/VBoxContainer/c_screen_font.visible = val
	$PreviewBack/Control/VBoxContainer/c_font_size.visible = val
