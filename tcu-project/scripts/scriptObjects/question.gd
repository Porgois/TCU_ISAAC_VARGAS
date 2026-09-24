class_name Question
extends Node

# Type of question
enum Type {MC, SA, MATCH, COMPLETION}

#region GENERAL
var question_id : int = -1
var theme : String = ""
var type : Type = Type.MC
var question : String = ""
var options : Array[String] = []
var answers : Array[String] = []
var was_answered_correctly : bool = false
#endregion

#region MATCH
class Pair:
	var term : String = ""
	var definitions : Array[String] = []

var pairs : Array[Pair]
#endregion

#region COMPLETION
class Blank:
	var blank : Array[String]
	
var blanks : Array[Blank] = []
#endregion

#region MISC
func toString() -> String:
	return "[%s] (%s) %s" % [Type.keys()[type], theme, question]
#endregion
