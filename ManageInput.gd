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
	for i in interpolation:
		%in_Interpol.add_item(i)
	%in_Interpol.selected = 1
	%in_size_y.text = "48"
	%in_size_x.text = "48"
	%in_Alpha.value = 0.3

func _on_in_subdiv_value_changed(value):
	%in_Subdiv.release_focus()
	if value >= 30:
		sd_warning.show()
	else: sd_warning.hide()


func _on_in_size_x_text_submitted(new_text : String):
	%in_size_x.release_focus()
	if !new_text.is_valid_int():
		%in_size_x.text = "48"
	if %in_size_x.text != "48": sz_warning.show()
	else: sz_warning.hide()


func _on_in_size_y_text_submitted(new_text : String):
	%in_size_y.release_focus()
	if !new_text.is_valid_int():
		%in_size_y.text = "48"
	if %in_size_y.text != "48": sz_warning.show()
	else: sz_warning.hide()


func _on_warning_pressed():
	%in_size_y.text = "48"
	%in_size_x.text = "48"
	sz_warning.hide()


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
