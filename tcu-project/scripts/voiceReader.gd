class_name VoiceReader
extends Node

# Default values
var default_pitch : float = 1.75
var default_volume : float = 1.0

# Audio files
@export var audio_character_array : Array[AudioStream] # 0 (a) - 26 (extra) [25 is z]

# Audio player
var audio_player : AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.pitch_scale = default_pitch
	audio_player.volume_db = linear_to_db(default_volume)
	
	add_child(audio_player)

func playCharacterSound(audio_index : int = 0):
	audio_player.stream = audio_character_array[audio_index]
	print("[VOICE READER] current stream: ", audio_player.stream.resource_path.get_file().get_basename())
	audio_player.play()

func characterToIndex(character : String) -> int:
	# Char to unicode
	var character_caps : String = character.to_upper()
	var index : int = character_caps.unicode_at(0) - 65 # ("A")
	
	return index

func playCharacter(character : String):
	var character_index : int = characterToIndex(character)
	
	if (character_index < 0 or character_index > 25):
		character_index = 26 # Extra character fallback
		
	playCharacterSound(character_index)
