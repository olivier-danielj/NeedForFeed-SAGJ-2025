extends Node2D

@export var need : Need.Type = Need.Type.HUNGRY
@export var bar_max = 100
@export var bar_min = 0
@export var bar_warn = 50

signal meltdown(type: Need.Type)
signal panic(type: Need.Type)
signal warn(type: Need.Type)
signal calm(type: Need.Type)

var once_warn : bool = false
var once_panic : bool = false

# Sprites
const SPR_HUNGRY = preload("res://sprites/bars/hungry.png")
const SPR_HUNGRY_BEHIND = preload("res://sprites/bars/hungry behind.png")
const SPD_HUNGRY = 0.5

const SPR_BORED = preload("res://sprites/bars/bored.png")
const SPR_BORED_BEHIND = preload("res://sprites/bars/bored behind.png")
const SPD_BORED = 0.25

const SPR_LOVE = preload("res://sprites/buttons/love.png")
const SPR_LOVE_BEHIND = preload("res://sprites/buttons/love_behind.png")
const SPD_LOVE = 0.08

const frequency = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_need()
	$Display.min_value = bar_min
	$Display.max_value = bar_max
	$Tick.start(frequency)

# Set bar's display sprites based on selected type
func set_need():
	match need:
		Need.Type.HUNGRY:
			$Display.texture_progress = SPR_HUNGRY
			$Display.texture_under = SPR_HUNGRY_BEHIND
			$Display.step = SPD_HUNGRY
		Need.Type.BORED:
			$Display.texture_progress = SPR_BORED
			$Display.texture_under = SPR_BORED_BEHIND
			$Display.step = SPD_BORED
		Need.Type.LOVE:
			$Display.texture_progress = SPR_LOVE
			$Display.texture_under = SPR_LOVE_BEHIND
			$Display.step = SPD_LOVE

# Emit warn or panic if value passes threshold
func _on_display_value_changed(value):
	if value >= bar_max:
		$Meltdown.start(3)
	match Need.Act(value):
		Need.Action.NONE:
			if once_warn or once_panic:
				once_warn = false
				once_panic = false
				calm.emit(need)
			return
		Need.Action.WARN:
			if once_warn: return 
			else: once_warn = true
			warn.emit(need)
		Need.Action.PANIC:
			if once_panic: return 
			else: once_panic = true
			panic.emit(need)

func _on_timer_timeout():
	$Display.value += $Display.step
	$Tick.start(frequency)

func _on_fill(type):
	$Display.value -= 10

func _on_meltdown_timeout():
	if !once_panic:
		return # calmed down
	meltdown.emit(need)
