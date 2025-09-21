extends Node2D

const spr_fish = preload("res://sprites/buttons/fish.png")
const spr_fish_under = preload("res://sprites/buttons/fish off.png")

const spr_mouse = preload("res://sprites/buttons/mouse.png")
const spr_mouse_under = preload("res://sprites/buttons/mouse off.png")

const spr_litter = preload("res://sprites/buttons/litter.png")
const spr_litter_under = preload("res://sprites/buttons/litter_off.png")

const spr_bed = preload("res://sprites/buttons/bed.png")
const spr_bed_under = preload("res://sprites/buttons/bed off.png")

const spr_money = preload("res://sprites/buttons/pig.png")
const spr_money_under = preload("res://sprites/buttons/pig off.png")

const spr_job = preload("res://sprites/buttons/job.png")
const spr_job_under = preload("res://sprites/buttons/job off.png")

@export var need : Need.Type = Need.Type.HUNGRY
var pressed : bool = false
const TICK = 0.2

signal fill(type : Need.Type)
signal warn(type: Need.Type)
signal panic(type: Need.Type)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_sprite()

func set_sprite() -> Resource:
	match need:
		Need.Type.HUNGRY:
			$Progress.texture_progress = spr_fish
			$Progress.texture_under = spr_fish_under
		Need.Type.BORED:
			$Progress.texture_progress = spr_mouse
			$Progress.texture_under = spr_mouse_under
		Need.Type.EEP:
			$Progress.texture_progress = spr_bed
			$Progress.texture_under = spr_bed_under
			$Progress.value = 100
			$Progress.fill_mode = $Progress.FILL_BOTTOM_TO_TOP
		Need.Type.STINK:
			$Progress.texture_progress = spr_litter
			$Progress.texture_under = spr_litter_under
			$Progress.value = 100
			$Progress.fill_mode = $Progress.FILL_TOP_TO_BOTTOM
		Need.Type.MONEY:
			$Progress.texture_progress = spr_money
			$Progress.texture_under = spr_money_under
			$Progress.value = 50
			$Progress.fill_mode = $Progress.FILL_BOTTOM_TO_TOP
		Need.Type.JOB:
			$Progress.texture_progress = spr_job
			$Progress.texture_under = spr_job_under
			$Progress.value = 0
			$Progress.fill_mode = $Progress.FILL_BOTTOM_TO_TOP
			$Tick.start(TICK)
	return spr_fish

func _on_button_pressed():
	if $Progress.value == 0:
		return
	match need:
		Need.Type.HUNGRY, Need.Type.BORED:
			$Progress.value -= 5
			fill.emit(need)
		Need.Type.MONEY:
			$Progress.value -= 20
			fill.emit(need)

func _on_button_button_down():
	match need:
		Need.Type.JOB, Need.Type.STINK:
			pressed = true
			$Tick.start(TICK)

func _on_button_button_up():
	pressed = false

func _on_tick_timeout():
	match need:
		Need.Type.JOB:
			if pressed:
				$Progress.value += 5
			else:
				$Progress.value -= 5
			if $Progress.value == $Progress.max_value:
				$Progress.value = $Progress.min_value
				fill.emit(need)
				$Tick.stop()
			if $Progress.value > $Progress.min_value:
				$Tick.start(TICK)
		Need.Type.STINK:
			if pressed:
				$Progress.value += 10
				if $Progress.value < $Progress.max_value:
					$Tick.start(TICK)
		Need.Type.EEP:
			$Progress.value += 5
			if $Progress.value >= $Progress.max_value:
				fill.emit(need)
				$Tick.stop()
			else:
				$Tick.start(TICK)

func _on_pig_fill(type):
	match need:
		Need.Type.HUNGRY, Need.Type.BORED:
			$Progress.value += 20

func _on_job_fill(type):
	if need != Need.Type.MONEY:
		return
	$Progress.value += 50

func _on_fish_fill(type):
	if need != Need.Type.STINK:
		return
	$Progress.value -= 4

func _on_mouse_fill(type):
	if need != Need.Type.EEP:
		return
	$Progress.value -= 10
	if $Progress.value <= 0:
		panic.emit(need)
	elif $Progress.value < 50:
		warn.emit(need)

func _on_karlotta_sleeping():
	if need == Need.Type.EEP:
		$Tick.start(TICK)
