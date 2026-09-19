class_name ExpressionHandler
extends Node

# Animators
@export var eye_animator : AnimationPlayer = null
@export var mouth_animator : AnimationPlayer = null
@export var body_animator : AnimationPlayer = null
@export var body_animation_tree : AnimationTree = null

# Blink
@export var blink_timer : Timer = null
@export var blink_frequency : Vector2 = Vector2.ZERO # X -> min, Y -> max

# Emotions
enum EMOTION {
	NEUTRAL,
	ANGRY,
	SAD,
	HAPPY
}

var current_emotion : EMOTION = EMOTION.NEUTRAL

func _ready() -> void:
	Global.setExpressionHandler(self) # Set to self for later use
	setRandomTimerTime()
	
	# Set blink state
	play_blink_animation()
	
	# Bind animation_finished signal
	if body_animation_tree:
		body_animation_tree.animation_finished.connect(_on_body_animation_finished)

#region BASICS

# Sets timers time to a random value between blink_frequency min and max
func setRandomTimerTime():
	var new_time : float = randf_range(blink_frequency.x, blink_frequency.y)
	blink_timer.wait_time = new_time

# Changes emotion if provided with an existing one
func changeEmotion(new_emotion : EMOTION = EMOTION.NEUTRAL):
	current_emotion = new_emotion
	print("[EXPRESSION HANDLER] Set new emotion to: ", current_emotion, ".\n")

#endregion

#region RESPONSES

func triggerPositiveReaction():
	changeEmotion(EMOTION.HAPPY)

func triggerNeutralReaction():
	changeEmotion(EMOTION.NEUTRAL)

func triggerNegativeReaction():
	changeEmotion(EMOTION.ANGRY)
	play_body_animation()

#endregion

#region ANIMATIONS

# Play blink animation according to emotion
func play_blink_animation():
	if eye_animator == null:
		printerr("[EXPRESSION HANDLER] Error: No eye animation player has been set!\n")
		return
	
	# Map emotion to prefix
	var animation_prefix : String = ""
	match current_emotion:
		EMOTION.NEUTRAL:
			animation_prefix = "neutral"
		EMOTION.ANGRY:
			animation_prefix = "angry"
	
	# Play animation
	eye_animator.play("EyeAnimations/" + animation_prefix + "_blink")

# Play speak animation according to emotion
func play_speak_animation():
	if mouth_animator == null:
		printerr("[EXPRESSION HANDLER] Error: No mouth animation player has been set!\n")
		return
	
	# Map emotion to prefix
	var animation_prefix : String = ""
	match current_emotion:
		EMOTION.NEUTRAL:
			animation_prefix = "neutral"
		EMOTION.ANGRY:
			animation_prefix = "angry"
	
	# Play animation
	mouth_animator.play("MouthAnimations/" + animation_prefix + "_speak")

# Play body animation according to emotion
func play_body_animation():
	if body_animation_tree == null:
		printerr("[EXPRESSION HANDLER] Error: No body animation tree has been set!\n")
		return
	
	# Reset all condition flags
	body_animation_tree.set("parameters/conditions/is_angry", false)
	
	# Set condition flag based on emotion
	# For now, any abnormal state (not neutral) will go back to neutral after finishing the animation
	match current_emotion: # Animation plays automatically
		EMOTION.ANGRY:
			body_animation_tree.set("parameters/conditions/is_angry", true)
		EMOTION.NEUTRAL: # Take all the values back to default
			body_animation_tree.set("parameters/conditions/is_angry", false)
#endregion


#region SIGNALS

# Sets new random wait time and starts again
func _on_blink_timer_timeout() -> void:
	# Blink
	play_blink_animation()
	
	# Timer reset
	setRandomTimerTime()
	blink_timer.start()

# Stops not-neutral body animations from playing more than once
func _on_body_animation_finished(animation_name : String = ""):
	# Only play once if not neutral
	if animation_name != "BodyAnimations/neutral_body":
		changeEmotion(EMOTION.NEUTRAL)
		body_animation_tree.set("parameters/conditions/is_angry", false) # Expand this to include more animations later on

#endregion
