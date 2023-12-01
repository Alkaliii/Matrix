extends Node


@onready var sd_warning = $"../HBoxContainer/Options/VBoxContainer/OptionsB/Subdivisions/HBoxContainer/Warning"
@onready var sz_warning = $"../HBoxContainer/Options/VBoxContainer/OptionsB/Size/HBoxContainer3/Warning"

const interpolation = [
	"NEAREST",
	"BILINEAR",
	"CUBIC",
	"TRILINEAR",
	"LANCZOS",
]

func _ready():
	Gsb.notify.connect(notify)
	Gsb.conA.connect(set_consoleA)
	Gsb.conB.connect(set_consoleB)
	for i in interpolation:
		%in_Interpol.add_item(i)
	%in_Interpol.selected = 1
	%in_size_y.text = "48"
	%in_size_x.text = "48"
	%in_Alpha.value = 0.3

func _on_in_subdiv_value_changed(value):
	%in_Subdiv.release_focus()
	if value > 13:
		sd_warning.show()
		Gsb.notify.emit(Gsb.n.SLOW_LOAD)
	else: 
		sd_warning.hide()
		Gsb.notify.emit(Gsb.n.ALL_GOOD)


func _on_in_size_x_text_submitted(new_text : String):
	%in_size_x.release_focus()
	await get_tree().process_frame
	if !new_text.is_valid_int():
		%in_size_x.text = "48"
	
	if %in_size_x.text != %in_size_y.text: 
		sz_warning.show()
		Gsb.notify.emit(Gsb.n.BAD_GENERATION)
	elif int(%in_size_x.text) > 48: 
		sz_warning.show()
		if int(%in_size_x.text) > 100: Gsb.notify.emit(Gsb.n.SLOW_LOAD)
		else: Gsb.notify.emit(Gsb.n.ALL_GOOD)
	else: 
		Gsb.update_image_info.emit()
		Gsb.notify.emit(Gsb.n.ALL_GOOD)
		sz_warning.hide()
	
	if %in_size_x.text == %in_size_y.text: Gsb.update_image_info.emit()


func _on_in_size_y_text_submitted(new_text : String):
	%in_size_y.release_focus()
	await get_tree().process_frame
	if !new_text.is_valid_int():
		%in_size_y.text = "48"
	
	if %in_size_x.text != %in_size_y.text: 
		sz_warning.show()
		Gsb.notify.emit(Gsb.n.BAD_GENERATION)
	elif int(%in_size_y.text) > 48: 
		sz_warning.show()
		if int(%in_size_y.text) > 100: Gsb.notify.emit(Gsb.n.SLOW_LOAD)
		else: Gsb.notify.emit(Gsb.n.ALL_GOOD)
	else: 
		Gsb.update_image_info.emit()
		Gsb.notify.emit(Gsb.n.ALL_GOOD)
		sz_warning.hide()
	
	if %in_size_x.text == %in_size_y.text: Gsb.update_image_info.emit()


func _on_warning_pressed():
	%in_size_y.text = "48"
	%in_size_x.text = "48"
	sz_warning.hide()
	Gsb.notify.emit(Gsb.n.ALL_GOOD)


func _on_in_optimize_pressed():
	%in_optimize.release_focus()
	if !%in_optimize.button_pressed:
		%in_color.set_pressed_no_signal(false)
		_on_in_color_pressed()


func _on_in_color_pressed():
	%in_color.release_focus()
	if !%in_color.button_pressed:
		%in_transparency.set_pressed_no_signal(false)
		_on_in_transparency_pressed()


func _on_in_transparency_pressed():
	%in_transparency.release_focus()


func _on_info_pressed():
	Gsb.info = !Gsb.info
	await get_tree().process_frame
	get_window().borderless = Gsb.info
	get_window().size = Vector2(1280,720)
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)


func _on_minimize_pressed():
	var TWEE = get_tree().create_tween()
	TWEE.tween_property(get_window(),"position:y",DisplayServer.screen_get_size().y + 90,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await TWEE.finished
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)
	get_tree().root.mode = Window.MODE_MINIMIZED

func notify(n : Gsb.n):
	var noti = %Notifcation_Center
	match n:
		Gsb.n.ALL_GOOD:
			noti.text = str("")
		Gsb.n.OVERFLOW: 
			noti.text = str("[color=656565]Some section overflows have occured. They have been marked in [color=deep pink]pink")
		Gsb.n.SLOW_LOAD:
			noti.text = str("[color=656565]The current settings will be [wave]slow[/wave] to load.")
		Gsb.n.CRASH_LIKELY:
			noti.text = str("[color=656565]The current settings will probably [color=orange red][shake]crash[/shake][/color] this program.")
		Gsb.n.BAD_GENERATION:
			noti.text = str("[color=656565]The current settings may generate [tornado]bad[/tornado] results.")

func set_consoleA(stri : String):
	%Console_A.text = str("[color=656565]",stri)
	await get_tree().create_timer(0.65).timeout
	%Console_A.text = ""

func set_consoleB(stri : String):
	%Console_B.text = str("[color=656565]",stri)
