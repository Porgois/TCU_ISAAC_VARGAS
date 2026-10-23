class_name QuizSession
extends RefCounted

# Scene paths to use in other scripts
const CUSTOM_QUIZ_PATH : String = "res://csvImports/customQuizzes/"
const CREATOR_SCENE_PATH : String = "res://scenes/ui/customQuestion/customQuizCreator.tscn"

# Set by the quiz list, consumed by the quiz creation menu
static var pending_csv_path : String = ""
