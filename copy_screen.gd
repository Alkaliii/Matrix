extends Button
class_name copy_screen

var data : String
var img_dat : Image

var wide = false

func _ready():
	self.add_to_group("prebtn")
	self.pressed.connect(copy)
	self.custom_minimum_size = Vector2(30,30)
	self.expand_icon = true
	self.alignment = HORIZONTAL_ALIGNMENT_LEFT

func _check_data():
	if data.count("#") < 3:
		self.disabled = true
	if data.count("#000") > 2301:
		self.disabled = true
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
	Gsb.preview_img.emit(img_dat)
	Gsb.test.emit(data)
	DisplayServer.clipboard_set(data)
	print("copied to clipboard!")
