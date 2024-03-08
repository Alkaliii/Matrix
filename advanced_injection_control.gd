extends Control

@onready var main_cont = $Back/MarginContainer
@onready var notifcation_center = %Notifcation_Center

@onready var selected_screen = $Back/MarginContainer/VBoxContainer/SelectionStatus/selected_screen
@onready var font_select = $Back/MarginContainer/VBoxContainer/c_screen_font/font_select
@onready var size_select = $Back/MarginContainer/VBoxContainer/c_font_size/size_select
@onready var code_edit = $Back/MarginContainer/VBoxContainer/CodeEdit

@onready var bpname = $Back/MarginContainer/VBoxContainer/bpname

var screen_count := 0
var scrn_idx := 0
var screen_data : Array = []
var bluename : String
var og_path : String

# Called when the node enters the scene tree for the first time.
func _ready():
	notifcation_center.text = ""
	get_parent().grab_focus()
	get_parent().close_requested.connect(close_window)

func close_window():
	get_parent().queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_notification(what : String,dura : float = 2.0):
	notifcation_center.text = str("[color=656565]",what)
	await get_tree().create_timer(dura).timeout
	notifcation_center.text = ""

func _on_open_sevo_pressed():
	#notifcation_center.text = ""
	
	var fd = FileDialog.new()
	fd.add_filter("*.sevo")
	#TODO DirMem
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.ok_button_text = "Select Blueprint"
	fd.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	fd.size = Vector2(800,500)
	fd.file_selected.connect(sevo_selected)
	fd.canceled.connect(_on_cancel_pressed)
	self.add_child(fd)
	fd.popup()

func sevo_selected(path : String):
	#into parse sevo to get screen count
	#a screen arrray filled with dictionaries will be created
	# [{}{}{}]
	# {
	#	"screen_content": "content",
	#	"screen_font": 0,
	#	"screen_font_size": 13
	#	}
	#this array will be read here when the player uses the select buttons
	#this array will be edited when the player makes changes
	#also take note of the blueprint name
	var sevo_file = load("res://sevo/Parse_sevo.cs")
	var parse_sevo = sevo_file.new()
	self.add_child(parse_sevo)
	
	parse_sevo.ReadMP4Injection(path)
	og_path = path
	screen_count = parse_sevo.injection_spread.size()
	screen_data = parse_sevo.injection_spread
	bluename = parse_sevo.mod_blueprint_name
	
	
	selected_screen.text = str("1/",screen_count)
	code_edit.text = screen_data[0].screen_content
	font_select.select(screen_data[0].screen_font)
	size_select.value = screen_data[0].screen_font_size
	bpname.text = bluename
	
	parse_sevo.queue_free()

func _on_cancel_pressed():
	set_notification("Operation Aborted")

func _on_inject_file_pressed():
	var fd = FileDialog.new()
	fd.add_filter("*.txt")
	#if Gsb.dir_mem != null: fd.current_dir = Gsb.dir_mem
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.ok_button_text = "Select File"
	fd.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	fd.size = Vector2(800,500)
	fd.file_selected.connect(file_selected)
	fd.canceled.connect(_on_cancel_pressed)
	self.add_child(fd)
	fd.popup()

func file_selected(path : String):
	var load_txt
	if FileAccess.file_exists(path):
		var loaded = FileAccess.open(path,FileAccess.READ)
		load_txt = loaded.get_as_text()
		code_edit.text = load_txt
		await get_tree().process_frame
		save_mod()
		#print(load_txt)
	else: 
		set_notification("Could Not Open File")

func select_up():
	var nidx = (scrn_idx + 1) % screen_count
	scrn_idx = nidx
	select_screen()
	set_notification("next >>>",0.25)

func select_down():
	var nidx = (scrn_idx - 1) % screen_count
	if nidx < 0: nidx = (screen_count - 1)
	scrn_idx = nidx
	select_screen()
	set_notification("<<< previous",0.25)

func select_screen():
	selected_screen.text = str(scrn_idx+1,"/",screen_count)
	code_edit.text = screen_data[scrn_idx].screen_content
	font_select.select(screen_data[scrn_idx].screen_font)
	size_select.value = screen_data[scrn_idx].screen_font_size

func save_mod():
	screen_data[scrn_idx].screen_content = code_edit.text
	screen_data[scrn_idx].screen_font = font_select.selected
	screen_data[scrn_idx].screen_font_size = size_select.value

func _on_prev_pressed():
	if screen_data.is_empty(): return
	save_mod()
	select_down()

func _on_next_pressed():
	if screen_data.is_empty(): return
	save_mod()
	select_up()

func _on_saveas_pressed():
	#check filename
	save_mod()
	if !is_filename_okay(): return
	#get save path
	save_to()
	#give parse sevo the deets
	#get byte matrix
	#save everything
	pass

func save_to():
	var fd = FileDialog.new()
	#fd.theme = $Control.theme
	#if Gsb.dir_mem != null: fd.current_path = Gsb.dir_mem
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.ok_button_text = "Select Folder"
	fd.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	fd.size = Vector2(800,500)
	fd.dir_selected.connect(dir_selected)
	fd.canceled.connect(_on_cancel_pressed)
	self.add_child(fd)
	fd.popup()

func dir_selected(save_folder : String):
	var sevo_file = load("res://sevo/Parse_sevo.cs")
	var parse_sevo = sevo_file.new()
	self.add_child(parse_sevo)
	
	parse_sevo.injection_spread = screen_data
	
	var dir = DirAccess
	var new_folder = str(save_folder,"/",bpname.text)
	
	if dir.dir_exists_absolute(new_folder): pass
	else:
		dir.make_dir_absolute(new_folder)
	
	parse_sevo.WriteMPFromInjection(og_path,bpname.text)
	await get_tree().process_frame
	var new_mp = parse_sevo.byte_matrix
	var file = str(new_folder,"/",bpname.text,".sevo")
	
	if FileAccess.file_exists(file):
		dir.copy_absolute(file, file + "bu")
	else: FileAccess.open(file + "bu",FileAccess.WRITE_READ).store_buffer(new_mp)
	
	var png = preload("res://matrix_large.png").get_image()
	png.resize(128,128,Image.INTERPOLATE_BILINEAR)
	png.save_png(str(new_folder,"/",bpname.text,".png"))
	
	FileAccess.open(file,FileAccess.WRITE_READ).store_buffer(new_mp)
	#notify finish?
	#notifcation_center.text = "[wave] Save Complete"
	set_notification("[wave] Save Complete")
	
	await get_tree().process_frame
	parse_sevo.queue_free()

func is_filename_okay() -> bool:
	if str(bpname.text).is_valid_filename(): 
		if bpname.text == bluename: bpname.text += "_EDIT"
		return true
	else:
		#notifcation_center.text = "Bad File Name"
		set_notification("Bad File Name")
		return false
