extends Node
#based off of xtpor/godot-msgpack on Github


@export var debug = true


# Called when the node enters the scene tree for the first time.
func _ready():
	var parse_sevo = load("res://sevo/Parse_sevo.cs").new()
	#parse_sevo.ReadMP("res://Matrix_16S_Template/Matrix_16S_Template.sevo")
	parse_sevo.ReadMP("C:/Users/aiaih/AppData/LocalLow/Moonfire Entertainment/Starship EVO/Save_Data/Blueprints/TestScreens/TestScreens.sevo")
	print("---")
	#parse_sevo.ReadMP("res://testGodot/testGodot.sevo")
	
	return
	var result = FileAccess.get_file_as_bytes("res://16Screen.sevo")
	
	var sevo_file = load("res://sevo/Parse_sevo.cs")
	var pa = sevo_file.new()
	
	
	
	var dir = DirAccess
	var bp_folder = "C:/Users/aiaih/AppData/LocalLow/Moonfire Entertainment/Starship EVO/Save_Data/Blueprints"
	var new_name = "testA"
	var new_folder = str(bp_folder,"/",new_name)
	
	if dir.dir_exists_absolute(new_folder): pass
	else:
		dir.make_dir_absolute(new_folder)
	pa.WriteMP(["He","Hi","Ho","Hum"],new_name,0,7.2)
	var new_mp = pa.byte_matrix
	var file = str(new_folder,"/",new_name,".sevo")
	
	if FileAccess.file_exists(file):
		dir.copy_absolute(file, file + "bu")
	
	FileAccess.open(file,FileAccess.WRITE_READ).store_buffer(new_mp)
	
	#pa.BreakMP("res://16Screen.sevo")
	#pa.BreakMP("C:/Users/aiaih/AppData/LocalLow/Moonfire Entertainment/Starship EVO/Save_Data/Blueprints/16ScreenEdit/16ScreenEdit.sevo")
	#"res://Matrix_16S_Template/Matrix_16S_Template.png"
	#print(result)
	#var dcde = self.decode(result)
	#print(dcde)
	#var dcde2 = self.decode(dcde.result[1])
	#print(dcde2)

static func decode(bytes):
	var buffer = StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.data_array = bytes
	
	var context = {error = OK,error_string = ""}
	var value = _decode(buffer,context)
	if context.error == OK:
		if buffer.get_position() == buffer.get_size():
			return {result = value, error = OK, error_string = ""}
		else:
			var msg = "something terribly wrong has occured (excess buffer %s bytes)" % [buffer.get_size() - buffer.get_position()]
			return {result = null, error = FAILED, error_string = msg}
	else:
		return {result = null, error = context.error, error_string = context.error_string}

static func _decode(b : StreamPeerBuffer,c : Dictionary):
	if b.get_position() == b.get_size():
		c.error = FAILED
		c.error_string = "unexpected end of input"
		return null
	
	var head = b.get_u8()
	
	#nil and boolean
	if head == 0xc0: return null
	elif head == 0xc2: return false
	elif head == 0xc3: return true
	
	#Integers
	elif head & 0x80 == 0:
		#positive fixnum
		print("positive fixum")
		return head
	elif (~head) & 0xe0 == 0:
		#negative fixnum
		print("negative fixum")
		return head - 256
	elif head == 0xcc:
		#unit 8
		print("unsigned 8")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for uint8"
			return null
		return b.get_u8()
	elif head == 0xcd:
		#unit 16
		print("unsigned 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for uint16"
			return null
		return b.get_u16()
	elif head == 0xce:
		#unit 32
		print("unsigned 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for uint32"
			return null
		return b.get_u32()
	elif head == 0xcf:
		#unit 64
		print("unsigned 64")
		if b.get_size() - b.get_position() < 8:
			c.error = FAILED
			c.error_string = "not enough buffer for uint64"
			return null
		return b.get_u64()
	elif head == 0xd0:
		#int 8
		print("int 8")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for int8"
			return null
		return b.get_8()
	elif head == 0xd1:
		#int 16
		print("int 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for int16"
			return null
		return b.get_16()
	elif head == 0xd2:
		#int 32
		print("int 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for int32"
			return null
		return b.get_32()
	elif head == 0xd3:
		#int 64
		print("int 64")
		if b.get_size() - b.get_position() < 8:
			c.error = FAILED
			c.error_string = "not enough buffer for int64"
			return null
		return b.get_64()
	
	#Float
	elif head == 0xca:
		#float 32
		print("float 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for float32"
			return null
		return b.get_float()
	elif head == 0xcb:
		#float 64
		print("float 64")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for float64"
			return null
		return b.get_double()
	
	#String
	elif (~head) & 0xa0 == 0:
		#fixstr
		print("fixed string")
		var size = head & 0x1f
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for fixstr. data required %s bytes" % [size]
			return null
		return b.get_utf8_string(size)
	elif head == 0xd9:
		#str 8
		print("str 8")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for str8 size"
			return null
		
		var size = b.get_u8()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for str8. data required %s bytes" % [size]
			return null
		return b.get_utf8_string(size)
	elif head == 0xda:
		#str 16
		print("str 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for str16 size"
			return null
		
		var size = b.get_u16()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for str16. data required %s bytes" % [size]
			return null
		return b.get_utf8_string(size)
	elif head == 0xdb:
		#str 32
		print("str 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for str32 size"
			return null
		
		var size = b.get_u32()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for str32. data required %s bytes" % [size]
			return null
		return b.get_utf8_string(size)
	
	#Binary
	elif head == 0xc4:
		#bin 8
		print("bin 8")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for bin8 size"
			return null
		
		var size = b.get_u8()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for bin8. data required %s bytes" % [size]
			return null
		
		var res = b.get_data(size)
		assert(res[0] == OK)
		return res[1]
	elif head == 0xc5:
		#bin 16
		print("bin 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for bin16 size"
			return null
		
		var size = b.get_u16()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for bin16. data required %s bytes" % [size]
			return null
		
		var res = b.get_data(size)
		assert(res[0] == OK)
		return res[1]
	elif head == 0xc6:
		#bin 32
		print("bin 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for bin32 size"
			return null
		
		var size = b.get_u32()
		if b.get_size() - b.get_position() < size:
			c.error = FAILED
			c.error_string = "not enough buffer for bin32. data required %s bytes" % [size]
			return null
		
		var res = b.get_data(size)
		assert(res[0] == OK)
		return res[1]
	
	#Array
	elif head & 0xf0 == 0x90:
		#arr
		print("array")
		var size = head & 0x0f
		var res = []
		for i in range(size):
			res.append(_decode(b,c))
			if c.error != OK: return null
		return res
	elif head == 0xdc:
		#arr 16
		print("array 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for array16 size"
			return null
		
		var size = b.get_u16()
		var res = []
		for i in range(size):
			res.append(_decode(b,c))
			if c.error != OK: return null
		return res
	elif head == 0xdd:
		#arr 32
		print("array 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for array32 size"
			return null
		
		var size = b.get_u32()
		var res = []
		for i in range(size):
			res.append(_decode(b,c))
			if c.error != OK: return null
		return res
	
	#Dictionary
	elif head & 0xf0 == 0x80:
		#map
		print("dictionary")
		var size = head & 0x0f
		var res = {}
		for i in range(size):
			var k = _decode(b,c)
			if c.error != OK: return null
			
			var v = _decode(b,c)
			if c.error != OK: return null
			
			res[k] = v
		return res
	elif head == 0xde:
		#map 16
		print("dictionary 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for map16 size"
			return null
		
		var size = b.get_u16()
		var res = {}
		for i in range(size):
			var k = _decode(b,c)
			if c.error != OK: return null
			
			var v = _decode(b,c)
			if c.error != OK: return null
			
			res[k] = v
		return res
	elif head == 0xdf:
		#map 32
		print("dictionary 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for map32 size"
			return null
		
		var size = b.get_u32()
		var res = {}
		for i in range(size):
			var k = _decode(b,c)
			if c.error != OK: return null
			
			var v = _decode(b,c)
			if c.error != OK: return null
			
			res[k] = v
		return res
	
	#Extentions
	elif head == 0xd4:
		#fixext 1
		print("fixed ext 1")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for fe1 size"
			return null
		
		var type = b.get_8()
		var data = b.get_data(1)
		return [type,data]
	elif head == 0xd5:
		#fixext 2
		print("fixed ext 2")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for fe2 size"
			return null
		
		var type = b.get_8()
		var data = b.get_data(2)
		return [type,data]
	elif head == 0xd6:
		#fixext 4
		print("fixed ext 4")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for fe4 size"
			return null
		
		var type = b.get_8()
		var data = b.get_data(4)
		return [type,data]
	elif head == 0xd7:
		#fixext 8
		print("fixed ext 8")
		if b.get_size() - b.get_position() < 8:
			c.error = FAILED
			c.error_string = "not enough buffer for fe8 size"
			return null
		
		var type = b.get_8()
		var data = b.get_data(8)
		return [type,data]
	elif head == 0xd8:
		#fixext 16
		print("fixed ext 16")
		if b.get_size() - b.get_position() < 16:
			c.error = FAILED
			c.error_string = "not enough buffer for fe16 size"
			return null
		
		var type = b.get_8()
		var data = b.get_data(16)
		return [type,data]
	elif head == 0xc7:
		#ext 8
		print("ext 8")
		if b.get_size() - b.get_position() < 1:
			c.error = FAILED
			c.error_string = "not enough buffer for e8 size"
			return null
		
		var N = b.get_u8()
		var type = b.get_8()
		var data = b.get_data(N)
		return [type,data]
	elif head == 0xc8:
		#ext 16
		print("ext 16")
		if b.get_size() - b.get_position() < 2:
			c.error = FAILED
			c.error_string = "not enough buffer for e16 size"
			return null
		
		var N = b.get_u16()
		var type = b.get_8()
		var data = b.get_data(N)
		
		var cdat
		if type == 99: #Buffer
			var nb = StreamPeerBuffer.new()
			nb.big_endian = true
			nb.data_array = data[1]
			cdat = _decode(nb,{}) if c.error == OK else null
			return [type,cdat]
		
		return [type,data]
	elif head == 0xc9:
		#ext 32
		print("ext 32")
		if b.get_size() - b.get_position() < 4:
			c.error = FAILED
			c.error_string = "not enough buffer for e32 size"
			return null
		
		var N = b.get_u32()
		var type = b.get_8()
		var data = b.get_data(N)
		return [type,data]
	else:
		c.error = FAILED
		c.error_string = "invalid byte tag %02X at pos %s" % [head, b.get_position()]
		return null
