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
	NEUTRAL, # 0
	ANGRY, # 1
	SAD, # 2
	HAPPY # 3
}

# React
enum ReactionMode { ALL, POSITIVE_ONLY, NEGATIVE_ONLY, NONE }
const BODY_STATE_NEUTRAL : String = "BodyAnimations_neutral_body"
const BODY_STATE_ANGRY : String = "BodyAnimations_angry_body"
var current_emotion : EMOTION = EMOTION.NEUTRAL

func _ready() -> void:
	Global.setExpressionHandler(self) # Set to self for later use
	setRandomTimerTime()
	
	# Set blink state
	play_blink_animation()

#region BASICS

# Sets timers time to a random value between blink_frequency min and max
func setRandomTimerTime():
	var new_time : float = randf_range(blink_frequency.x, blink_frequency.y)
	blink_timer.wait_time = new_time

# Changes emotion if provided with an existing one
func changeEmotion(new_emotion : EMOTION = EMOTION.NEUTRAL):
	current_emotion = new_emotion
	print("[EXPRESSION HANDLER] Set new emotion to: ", current_emotion, ".\n")

# Reroute reaction handling
func reactToResult(mode : ReactionMode, correct : bool) -> bool:
	if not shouldReact(mode, correct):
		return false
	if correct:
		triggerNeutralReaction()
	else:
		triggerNegativeReaction()
	return true

#endregion

#region REACTIONS

# Decides the extent of the teacher's reaction (only positive, only negative, both, neither)
func shouldReact(mode : ReactionMode, correct : bool) -> bool:
	match mode:
		ReactionMode.ALL: return true
		ReactionMode.POSITIVE_ONLY: return correct
		ReactionMode.NEGATIVE_ONLY: return not correct
		_: return false

#endregion

#region RESPONSES

func triggerPositiveReaction():
	changeEmotion(EMOTION.HAPPY)
	play_eye_animation()

func triggerNeutralReaction():
	changeEmotion(EMOTION.NEUTRAL)
	play_eye_animation()

func triggerNegativeReaction():
	changeEmotion(EMOTION.ANGRY)
	play_eye_animation()
	play_body_animation()

#endregion

#region ANIMATIONS
# Play eye animationa according to emotion
func play_eye_animation():
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
	eye_animator.play("EyeAnimations/" + animation_prefix + "_eyes")

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
	
	var playback := body_animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	if playback == null:
		printerr("[EXPRESSION HANDLER] Error: Body animation tree has no state machine playback!\n")
		return
	
	# start() jumps straight to the state and restarts it from the beginning,
	# so it works even if the animation was already playing
	match current_emotion:
		EMOTION.ANGRY:
			playback.start(BODY_STATE_ANGRY)
		EMOTION.NEUTRAL:
			playback.start(BODY_STATE_NEUTRAL)

#endregion

#region SIGNALS

# Sets new random wait time and starts again
func _on_blink_timer_timeout() -> void:
	# Blink
	play_blink_animation()
	
	# Timer reset
	setRandomTimerTime()
	blink_timer.start()

#endregion
