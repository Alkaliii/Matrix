@tool
extends Node

@onready var copy_module = $Control/HBoxContainer/Preview/HBoxContainer/CopyModule
@onready var cmb_scroll_container = $Control/HBoxContainer/Preview/HBoxContainer/CMBScrollContainer
@onready var copy_module_b = $Control/HBoxContainer/Preview/HBoxContainer/CMBScrollContainer/CopyModuleB
@onready var preview_grid = $Control/HBoxContainer/Preview/HBoxContainer/PreviewGrid
@onready var uploaded_image = $Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage
@onready var upload = $Control/HBoxContainer/Options/VBoxContainer/OptionsB/Upload
@onready var regen = $Control/HBoxContainer/Options/VBoxContainer/OptionsB/Regen

@export var image : Texture2D
@export_range(1,99,1) var subdiv : int = 1 #past 16 you need to generate a scroll container list
@export var interpolation : Image.Interpolation = Image.INTERPOLATE_BILINEAR #itp = itp.BILINEAR
@export var size := Vector2(48,48)

@export var vertical_offset : int = 0 #217
var custom_adjustments := "<align=center><line-height=16.75%><cspace=-0.11em>"
@export_range(0,1,0.01) var alpha_threshold = 0.3
@export var prevent_repeat_color := false : set = prc_set
@export var better_color := false : set = bc_set
@export var with_transparency := false

var override_font = 0
var override_font_size = 7.2

const gridm = preload("res://gridm.tscn")

const icn_cornerA = preload("res://icons/rounded_corner_FILL0_wght400_GRAD0_opsz48.svg")
const icn_cornerB = preload("res://icons/rounded_corner_FILL0_wght400_GRAD0_opsz48b.svg")
const icn_cornerC = preload("res://icons/rounded_corner_FILL0_wght400_GRAD0_opsz48c.svg")
const icn_cornerD = preload("res://icons/rounded_corner_FILL0_wght400_GRAD0_opsz48d.svg")
const icn_top = preload("res://icons/border_top_FILL0_wght400_GRAD0_opsz48.svg")
const icn_bottom = preload("res://icons/border_bottom_FILL0_wght400_GRAD0_opsz48.svg")
const icn_left = preload("res://icons/border_left_FILL0_wght400_GRAD0_opsz48.svg")
const icn_right = preload("res://icons/border_right_FILL0_wght400_GRAD0_opsz48.svg")
const icn_inner = preload("res://icons/border_inner_FILL0_wght400_GRAD0_opsz48.svg")
const icn_clear = preload("res://icons/border_clear_FILL0_wght400_GRAD0_opsz48.svg")
const greeting = ["[wave]Hello!","[wave]Yellow!","[wave]Hi!","[shake]Heyyo!","[wave]Whats up!","[wave]Yo!","[tornado]Hmm..."]

var cropped = false
var listThreshold = 11

var entityName = ""
var save_folder = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().set_size(Vector2(1280,720))
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)
	if not Engine.is_editor_hint():
		Gsb.preview_img.connect(preview)
		Gsb.update_image_info.connect(set_image_info)
		Gsb.update_section_info.connect(set_section_info)
		Gsb.hex_ui.connect(set_customs)
		Gsb.test.connect(test)
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Welcome.text = str(greeting.pick_random())
		
		get_viewport().set_embedding_subwindows(false)
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Subdivisions.hide()
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Alpha_threshold.hide()
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Interpolation.hide()
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Vertical_Offset.hide()
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Size.hide()
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Regen.hide()
		$Control/HBoxContainer/Preview/ToggleOptions.hide()
		$Control2/PanelContainer/bar/Start/SaveSevo.hide()
		$Control2/PanelContainer/bar/Start/OpenHex.hide()
		
		uploaded_image.texture = preload("res://ram.png")
		image = null
#		grid.material.set_shader_parameter("size",Vector2(250,250))
#		grid.material.set_shader_parameter("grid_size",floor(250.0/float(subdiv)))
#		var lw = ceil(250.0/float(subdiv)) / 250.0
#		print(lw)
#		grid.material.set_shader_parameter("line_width",lw if subdiv > 16 else 0.1)
	#create_dot_matrix()
	pass # Replace with function body.

func setgrid():
	for m in $Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage/gridx.get_children():
		m.queue_free()
	for m in $Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage/gridy.get_children():
		m.queue_free()
	
	for m in subdiv:
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage/gridx.add_child(gridm.instantiate())
		$Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage/gridy.add_child(gridm.instantiate())
		if m % 2 == 0:
			await get_tree().process_frame
		if m > 50: break

func prc_set(value):
	prevent_repeat_color = value
	if value == false: better_color = false

func bc_set(value):
	better_color = value
	if value == false: with_transparency = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func test(s = null):
	pass
	#optimize(s)

func preview(img : Image):
	if Engine.is_editor_hint(): return
	for i in preview_grid.get_children():
		i.queue_free()
	
	var sz = image.get_size()
	if size[size.max_axis_index()] > sz[sz.max_axis_index()]:
		return
	
	var base = img.get_size()
	preview_grid.columns = base.x
	#print("base",base)
	for y in base.y:
		for x in base.x:
			var px = ColorRect.new()
			px.color = img.get_pixel(x,y)
			px.custom_minimum_size = Vector2(round(288/base.x),round(288/base.y))
			preview_grid.add_child(px)

func cut_image():
	if Engine.is_editor_hint(): return
	Gsb.kill_old_cut = true
	for i in copy_module.get_children(): i.queue_free()
	for i in copy_module_b.get_children(): i.queue_free()
	await get_tree().process_frame
	Gsb.kill_old_cut = false
	
	var cut = image.get_image()
	var base = image.get_size()
	var ratio = 1
	if base.x != base.y:
		var b = [base.x,base.y]
		cut.crop(base[base.max_axis_index()],base[base.max_axis_index()])
		cropped = true
	else:
		cropped = false
	
	cut.resize(size.x * subdiv,size.y * subdiv,interpolation)
	
	var slower = false
	var sz = image.get_size()
	if size[size.max_axis_index()] > sz[sz.max_axis_index()]:
		slower = true
	
	
	var cutup := []
	for y in subdiv:
		for x in subdiv:
			cutup.append(cut.get_region(Rect2(Vector2(x * size.x,y * size.y),size)))
			if slower: await get_tree().process_frame
	
	print(cutup.size()," screens")
	Gsb.conB.emit(str("[",cutup.size(),"] sections"))
	copy_module.columns = subdiv
	var idx = 0
	var wide = false if subdiv < listThreshold else true
	copy_module.visible = !wide
	cmb_scroll_container.visible = wide
	for i in cutup:
		var cs = copy_screen.new()
		cs.wide = wide
		cs.icon = get_icon(idx)
		cs.data = create_dot_matrix_from_image(i)
		if slower: await get_tree().process_frame
		cs.px_count = size[size.max_axis_index()] * size[size.max_axis_index()]
		cs.img_dat = i
		if wide:
			cs.text = str("Screen ",cutup.find(i) + 1)
			copy_module_b.add_child(cs)
		else:
			copy_module.add_child(cs)
		cs._check_data()
		if cropped or wide: cs._shrink_disabled()
		idx += 1
		if idx % 2 == 0 and [true,false].pick_random():
			await get_tree().process_frame
		if Gsb.kill_old_cut == true: break
	
	await get_tree().process_frame
	if wide:
		for i in copy_module_b.get_children():
			if !i is copy_screen: continue
			if i.disabled == false:
				i.copy()
				break
	else:
		for i in copy_module.get_children():
			if !i is copy_screen: continue
			if i.disabled == false:
				i.copy()
				break
	

func get_icon(idx : int):
	var duo = subdiv - 1
	var tri = ((subdiv * subdiv) - subdiv)
	var tetra = (subdiv * subdiv) - 1
	var left = []
	var right = [(subdiv * 2 - 1)]
	for i in subdiv - 1:
		if subdiv * i == 0: continue
		left.append(subdiv * i)
	for i in subdiv - 2:
		right.append(right[right.size()-1] + subdiv)
	
	match idx:
		0: #First Corner
			return icn_cornerD
		duo: #Second Corner
			return icn_cornerA
		tri: #Third Corner
			return icn_cornerC
		tetra:
			return icn_cornerB
	if idx in left: return icn_left
	if idx in right: return icn_right
	if idx > 0 and idx < duo: return icn_top
	if idx > tri and idx < tetra: return icn_bottom
	return icn_inner

func create_dot_matrix_from_image(img : Image):
	if Engine.is_editor_hint(): return
	var pixel = "."
	#img.resize(size.x,size.y,interpol)
	var output : String = ""
	if vertical_offset != 0:
		output += str("<line-height=",vertical_offset * -1,">")
		output += "\n"
	if custom_adjustments != "":
		output += custom_adjustments#"<align=center><line-height=16.75%><cspace=-0.11em>"
		output += "\n"
	
	var prev_code = ""
	var color_code = ""
	
	for y in size.y:
		for x in size.x:
			var px = img.get_pixel(x,y)
			var hex = px.to_html(true if with_transparency and px.a != 1 else false)
			var shex = to_hexa([px.r8,px.g8,px.b8])
			if better_color:
				#generate whole ass color code
				if hex.count(hex[0]) == 6: #Shortens aaaaaa to aaa
					hex = hex.substr(0,3)
				if Color.html(hex).is_equal_approx(Color.html(shex)): #Should turn aabbcc to abc
					color_code = str("<#",shex,">")
				else:
					color_code = str("<#",hex,">")
				if color_code in ["<#000000>","<#00000000>"]: color_code = "<#000>" #Cleans up null
				if px.a == 0: color_code = "<#000>" #Cleans up null
			else:
				#generate shortened color code
				if (px.a < alpha_threshold):
					#alpha cut
					shex = "000"
				color_code = str("<#",shex,">")
			
			#Add to output
			if color_code.match(prev_code) and prevent_repeat_color:
				output += pixel
			else:
				output += str(color_code,pixel)
				prev_code = color_code
		if y != size.y: output += "\n"
	
	return output

#func create_dot_matrix():
#	var img = image.get_image()
#	img.resize(size.x,size.y,interpolation)
#	var output : String = ""
#	if vertical_offset != 0:
#		output += str("<line-height=",vertical_offset * -1,">")
#		output += "\n"
#	output += "<align=center><line-height=16.75%><cspace=-0.11em>"
#	output += "\n"
#
#	for y in size.y:
#		for x in size.x:
#			var px = img.get_pixel(x,y)
#			var rgb = [px.r8,px.g8,px.b8]
#			var shex = to_hexa(rgb)
#			if px.a > alpha_threshold: output += str("<#",shex,">.")
#			else: output += str("<#000>.")
#		if y != size.y: output += "\n"
#
#	DisplayServer.clipboard_set(output)
#	print("copied to clipboard!")

const hv = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
func to_hexa(col):
	col[0] = round(round(col[0] / 2.55) /17)
	col[1] = round(round(col[1] / 2.55) /17)
	col[2] = round(round(col[2] / 2.55) /17)
	return str(hv[col[0]],hv[col[1]],hv[col[2]])

#func optimize(txt : String):
#	var code_idx = []
#	#find all color codes
#	for s in txt.count("<#"):
#		if code_idx.is_empty(): code_idx.append(txt.find("<#"))
#		else: code_idx.append(txt.find("<#",code_idx[code_idx.size()-1]+1))
#	#remove dupes
#	var prev_code = ""
#	var new_code = ""
#
#	for c in code_idx:
#		var LEN = -1
#		if code_idx.size() > code_idx.find(c)+1:
#			LEN = 6
#		new_code = txt.substr(c,LEN).replace(".","")
#		if prev_code.match(new_code):
#			#previous == current \ kill duplicate
#			for s in 6:
#				txt[c + s] = "✦"
#		else:
#			print(prev_code)
#			prev_code = new_code
#
#	#cleanup
#	txt = txt.replace("✦","")
#	await get_tree().create_timer(1).timeout
#	DisplayServer.clipboard_set(txt)
#	#print(txt)

func hide_welcome():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Welcome.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Basic.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples.hide()
	Gsb.help_ui.emit("CLOSE")

func _on_upload_pressed():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Upload.release_focus()
	hide_welcome()
	
	var fd = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	#fd.filters.append_array(PackedStringArray(["*.png","*.jpg","*.jpeg","*.svg","*.webp"]))
	fd.add_filter("*.png","Image")
	fd.add_filter("*.jpg","Image")
	fd.add_filter("*.jpeg","Image")
	fd.add_filter("*.svg","Image")
	fd.add_filter("*.webp","Image")
	fd.ok_button_text = "Upload"
	fd.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	fd.size = Vector2(800,500)
	fd.file_selected.connect(load_selected)
	self.add_child(fd)
	fd.popup()

func show_options():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Subdivisions.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Alpha_threshold.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Interpolation.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Vertical_Offset.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Size.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Regen.show()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Upload.show()
	$Control/HBoxContainer/Preview/ToggleOptions.show()
	$Control2/PanelContainer/bar/Start/SaveSevo.show()
	$Control2/PanelContainer/bar/Start/OpenHex.show()
	if subdiv < listThreshold: $Control/HBoxContainer/Preview/HBoxContainer/CopyModule.show()
	else: $Control/HBoxContainer/Preview/HBoxContainer/CMBScrollContainer.show()

func hide_some_options():
	#$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Subdivisions.hide()
	#$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Alpha_threshold.hide()
	#$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Interpolation.hide()
	#$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Vertical_Offset.hide()
	#$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Size.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Regen.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Upload.hide()
	$Control/HBoxContainer/Preview/HBoxContainer/CopyModule.hide()
	$Control/HBoxContainer/Preview/HBoxContainer/CMBScrollContainer.hide()
	#$Control/HBoxContainer/Preview/ToggleOptions.hide()

func set_image_info():
	size = Vector2(int(%in_size_x.text),int(%in_size_y.text))
	var ii = $Control/HBoxContainer/Options/VBoxContainer/OptionsB/UploadedImage/image_info
	var sz = image.get_size()
	var ss = round(sz[sz.max_axis_index()]/size[size.max_axis_index()])
	ii.text = str("src: ",sz.x,"x",sz.y," \n[color=gray]suggested subdiv: ",ss if ss <= 16 else 16)

func set_section_info(char_count,px_count):
	var prc = floor(char_count/16300.0 * 100)
	$Control/HBoxContainer/Preview/section_info.text = str("sec: / char: ",char_count,"/16300 (",prc,"%) / ",px_count," px")

func load_selected(path : String):
	show_options()
	print(path)
	
	var new_img = Image.new()
	var data = new_img.load_from_file(path)
	var imgtex = ImageTexture.new()
	var img = imgtex.create_from_image(data)
	
	image = img#load(path)
	uploaded_image.texture = image
	set_image_info()
	generate()

func _on_regen_pressed():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Regen.release_focus()
	generate()

func generate():
	Gsb.notify.emit(Gsb.n.ALL_GOOD)
	subdiv = int(%in_Subdiv.value)
	alpha_threshold = float(%in_Alpha.value)
	interpolation = %in_Interpol.selected
	vertical_offset = int(%in_Vertical.value)
	size = Vector2(int(%in_size_x.text),int(%in_size_y.text))
	var sz = image.get_size()
	if size[size.max_axis_index()] > sz[sz.max_axis_index()]:
		Gsb.notify.emit(Gsb.n.CRASH_LIKELY)
		await get_tree().create_timer(1).timeout
	
	prevent_repeat_color = %in_optimize.button_pressed
	better_color = %in_color.button_pressed
	with_transparency = %in_transparency.button_pressed
	
	await cut_image()
	setgrid()

const ramA = preload("res://ram.png")
const ramB = preload("res://Ram_Infobox.png")
const godot = preload("res://icon.svg")
func _on_ea_pressed():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples/ea.release_focus()
	hide_welcome()
	show_options()
	image = ramA
	uploaded_image.texture = image
	set_image_info()
	generate()


func _on_eb_pressed():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples/eb.release_focus()
	hide_welcome()
	show_options()
	image = ramB
	uploaded_image.texture = image
	set_image_info()
	generate()


func _on_ec_pressed():
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples.hide()
	$Control/HBoxContainer/Options/VBoxContainer/OptionsB/Examples/ec.release_focus()
	hide_welcome()
	show_options()
	image = godot
	uploaded_image.texture = image
	set_image_info()
	generate()

func show_nd():
	if !entityName.is_valid_filename(): $Control2/namebp/name.text = ""
	else: $Control/ManageInput._on_name_text_changed(entityName)
	
	if $Control2/namebp.visible:
		$Control/ManageInput.animate_export("OUT")
		show_options()
	else:
		$Control/ManageInput.animate_export("IN")
		hide_some_options()
	#$Control2/namebp.show()

func _on_save_sevo_pressed():
	if true:#subdiv <= 16:
		show_nd()
	else:
		#warning
		Gsb.notify.emit(Gsb.n.TOO_MANY_FOR_EXPORT) 
		return

func _on_cancel_pressed():
	$Control/ManageInput.animate_export("OUT")
	show_options()
	if entityName.is_valid_filename():
		$Control2/namebp/name.text = entityName
	#$Control2/namebp.hide()

func _on_confirm_pressed():
	#$Control2/namebp.hide()
	entityName = $Control2/namebp/name.text
	entityName.to_camel_case()
	if !entityName.is_valid_filename():
		#warning
		Gsb.notify.emit(Gsb.n.BAD_EXPORT_NAME) 
		entityName = "MatrixExport"
		$Control2/namebp/name.text = entityName
		$Control/ManageInput._on_name_text_changed(entityName)
		return
	
	_on_cancel_pressed()
	Gsb.notify.emit(Gsb.n.ALL_GOOD) 
	
	var fd = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.ok_button_text = "Select Folder"
	fd.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	fd.size = Vector2(800,500)
	fd.dir_selected.connect(dir_selected)
	fd.canceled.connect(_on_cancel_pressed)
	self.add_child(fd)
	fd.popup()

func dir_selected(path : String):
	save_folder = path
	
	var array_matrix = get_matrixB()
	var sevo_file = load("res://sevo/Parse_sevo.cs")
	var parse_sevo = sevo_file.new()
	self.add_child(parse_sevo)
	
	var dir = DirAccess
	var new_folder = str(save_folder,"/",entityName)
	
	if dir.dir_exists_absolute(new_folder): pass
	else:
		dir.make_dir_absolute(new_folder)
	
	#parse_sevo.WriteMP(array_matrix,entityName,override_font,override_font_size)
	parse_sevo.CreateMP(array_matrix,subdiv,entityName,override_font,override_font_size)
	await get_tree().process_frame
	var new_mp = parse_sevo.byte_matrix
	var file = str(new_folder,"/",entityName,".sevo")
	
	if FileAccess.file_exists(file):
		dir.copy_absolute(file, file + "bu")
	else: FileAccess.open(file + "bu",FileAccess.WRITE_READ).store_buffer(new_mp)
	
	var png = image.get_image()
	png.resize(128,128,Image.INTERPOLATE_BILINEAR)
	png.save_png(str(new_folder,"/",entityName,".png"))
	
	var pre = get_window().get_viewport().get_texture().get_image()
	var factor = Vector2(960,540)/Vector2(pre.get_size())
	pre.resize(round(pre.get_size().x * factor.x),round(pre.get_size().y * factor.y),Image.INTERPOLATE_BILINEAR)
	pre.save_png(str(new_folder,"/",entityName,"_preview.png"))
	
	FileAccess.open(file,FileAccess.WRITE_READ).store_buffer(new_mp)
	#notify finish?
	
	await get_tree().process_frame
	parse_sevo.queue_free()

func get_matrixB():
	var cm = copy_module.get_children() if copy_module.visible else copy_module_b.get_children()
	var matrix = PackedStringArray()
	
	for i in cm:
		if !i is copy_screen: continue
		matrix.append(i.data if !i.disabled else Gsb.delete_screen)
	
	return matrix

func get_matrix():
	var cm = copy_module.get_children() if copy_module.visible else copy_module_b.get_children()
	var matrix = PackedStringArray()
	
	#for i in 256:
		#matrix.append(str(i))
	#return matrix
	
	var idx = 0
	
	for i in cm:
		if !i is copy_screen: continue
		matrix.append(i.data if !i.disabled else Gsb.delete_screen)
		if idx == subdiv and subdiv < 16:
			#end of row?
			idx = 0
			for e in 16-subdiv:
				matrix.append(Gsb.delete_screen)
		idx += 1
	
	for i in 256 - matrix.size():
		matrix.append(Gsb.delete_screen)
	
	return matrix


func _on_home_pressed():
	get_tree().reload_current_scene()

func set_customs(val):
	var hexuin = $"Control/Hex-Edit"
	var old_ad = custom_adjustments
	if hexuin.ca:
		override_font = hexuin.cf
		override_font_size = hexuin.cfs
		custom_adjustments = str(hexuin.adju)
		print("hi")
	else:
		override_font = 0
		override_font_size = 7.2
		custom_adjustments = "<align=center><line-height=16.75%><cspace=-0.11em>"
	await get_tree().create_timer(0.5).timeout
	if val == "CLOSE" and old_ad != custom_adjustments: generate()


func _on_rotate_pressed():
	if image:
		var ri = image.get_image()
		ri.rotate_90(COUNTERCLOCKWISE)
		var im = ImageTexture.new()
		var imr = im.create_from_image(ri)
		uploaded_image.texture = imr
		image = imr
