extends Button
class_name copy_screen

var data : String
var img_dat : Image
var px_count : int

var wide = false
var overflow = false

func _ready():
	self.add_to_group("prebtn")
	self.pressed.connect(copy)
	self.custom_minimum_size = Vector2(30,30)
	self.expand_icon = true
	self.alignment = HORIZONTAL_ALIGNMENT_LEFT
	Gsb.preview_img.connect(_memory)

func _memory(g=null):
	if !overflow:
		self.modulate = Color.WHITE
	else: self.modulate = Color.DEEP_PINK

func _check_data():
	if data.count("#") < 3 and data.count("#000") == data.count("#"):
		self.disabled = true
	if data.count("#000") > px_count - 3:
		self.disabled = true
	if data.length() > 16300:
		overflow = true
		self.modulate = Color.DEEP_PINK
		Gsb.notify.emit(Gsb.n.OVERFLOW)
		#self.icon = Gsb.icn_clear

func _shrink_disabled():
	if disabled:
		#self.icon = null
		if wide:
			self.hide()
			self.text = ""
			self.custom_minimum_size = Vector2(30,1)
		else: self.custom_minimum_size = Vector2(1,30)

func copy():
	self.grab_click_focus()
	Gsb.preview_img.emit(img_dat)
	#Gsb.test.emit(data)
	DisplayServer.clipboard_set(data)
	print("copied to clipboard!")
	Gsb.conA.emit(str("copied to clipboard!"))
	await get_tree().process_frame
	self.modulate = Color.AQUA
