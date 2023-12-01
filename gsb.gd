extends Node

signal close_matrix
signal preview_img
signal update_image_info
signal notify
signal conA
signal conB
signal test

var info := true

var kill_old_cut = false

enum n {
	ALL_GOOD,
	OVERFLOW,
	SLOW_LOAD,
	CRASH_LIKELY,
	BAD_GENERATION,
	PREVIEW_DISABLED
}

const icn_clear = preload("res://icons/border_clear_FILL0_wght400_GRAD0_opsz48.svg")
