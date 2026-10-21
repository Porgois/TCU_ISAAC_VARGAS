class_name FileReader
extends Node

# Delimiters
var option_delimiter : String = ";"
var answer_delimiter : String = "/"

# Types
const TYPE_MAP := {
	"MC": Question.Type.MC,
	"SA": Question.Type.SA,
	"MATCH": Question.Type.MATCH,
	"COMPLETION": Question.Type.COMPLETION
}

# Header for exporting
const CSV_HEADER : PackedStringArray = ["theme", "type", "prompt", "options", "answer"]

# Remembers where the last csv was loaded from, so saving can default to it if need be
var last_loaded_path : String = ""

#region LOADING
func loadCSVQuestions(csv_path: String) -> Array[Question]:
	var questions : Array[Question] = []
	
	var file : FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	
	# Invalid file
	if file == null:
		printerr("ERROR: No '.csv' file found at: ", csv_path, "!\n")
		return questions
	
	# Skip first row (header row)
	if not file.eof_reached():
		file.get_csv_line()
	
	var next_id : int = 0
	while not file.eof_reached():
		var row : PackedStringArray = file.get_csv_line()
		
		# Skip blank lines
		if row.is_empty() or (row.size() == 1 and row[0].strip_edges() == ""):
			continue
		
		# Store transformed question in question array
		var question = rowToQuestion(row, next_id)
		if question != null:
			questions.append(question)
			next_id += 1
	
	file.close()
	return questions

func rowToQuestion(row : PackedStringArray, id : int) -> Question:
	# Pad in case a row is missing empty columns
	var cells : Array = row
	while cells.size() < 5:
		cells.append("")
	
	# Load row values
	var theme : String = String(cells[0]).strip_edges()
	var type_string : String = String(cells[1]).strip_edges().to_upper()
	var prompt : String = String(cells[2]).strip_edges()
	var options_string : String = String(cells[3]).strip_edges()
	var answer_string : String = String(cells[4]).strip_edges()
	
	# Check for invalid question type
	if not TYPE_MAP.has(type_string):
		printerr("WARNING: Unknown question type '", type_string, "' - skipping row: ", row)
		return null
	
	# Create new question with row values
	var new_question : Question = Question.new()
	new_question.question_id = id
	new_question.theme = theme
	new_question.type = TYPE_MAP[type_string]
	new_question.question = prompt
	
	# Parse based on question type
	match new_question.type:
		Question.Type.MC: # Multiple choice
			parseMC(new_question, options_string, answer_string)
		Question.Type.SA: # Short answer
			parseSA(new_question, answer_string)
		Question.Type.MATCH: # Match
			parseMATCH(new_question, options_string)
		Question.Type.COMPLETION: # Completion
			parseCOMPLETION(new_question, answer_string)
	
	return new_question
#endregion

#region EXPORTING

# Saves a Quiz object to a csv file. If no path is given, uses the last loaded path.
func saveQuizToCSV(quiz : Quiz, csv_path : String = "") -> bool:
	if quiz == null:
		printerr("ERROR: Cannot save a null quiz!\n")
		return false
	
	print("WORKED HERE!")
	return saveQuestionsToCSV(quiz.questions, csv_path)

func saveQuestionsToCSV(questions : Array[Question], csv_path : String = "") -> bool:
	# Fall back to the path the questions were loaded from
	if csv_path == "":
		csv_path = last_loaded_path
	if csv_path == "":
		printerr("ERROR: No csv path given and no file has been loaded yet!\n")
		return false
	
	print("[FILE READER] Saving to path: '", csv_path, "'")
	
	# Create the folder(s) if they don't exist yet
	var dir_path : String = csv_path.get_base_dir()
	if dir_path != "" and not DirAccess.dir_exists_absolute(dir_path):
		var dir_error : Error = DirAccess.make_dir_recursive_absolute(dir_path)
		if dir_error != OK:
			printerr("ERROR: Could not create folder '", dir_path, "': ", error_string(dir_error), "\n")
			return false
	
	# WRITE creates the file if it doesn't exist (and overwrites it if it does)
	var file : FileAccess = FileAccess.open(csv_path, FileAccess.WRITE)
	if file == null:
		printerr("ERROR: Could not open '", csv_path, "' for writing: ", error_string(FileAccess.get_open_error()), "\n")
		return false
	
	file.store_csv_line(CSV_HEADER)
	for question in questions:
		if question != null:
			file.store_csv_line(questionToRow(question))
	file.close()
	
	print("[FILE READER] Saved ", questions.size(), " questions to: ", ProjectSettings.globalize_path(csv_path), "\n")
	return true

# Opposite of rowToQuestion()
func questionToRow(question : Question) -> PackedStringArray:
	var options_string : String = ""
	var answer_string : String = ""
	
	match question.type:
		Question.Type.MC: # Multiple choice
			options_string = option_delimiter.join(question.options)
			answer_string = answer_delimiter.join(question.answers)
		Question.Type.SA: # Short answer
			answer_string = answer_delimiter.join(question.answers)
		Question.Type.MATCH: # Match
			options_string = matchPairsToString(question.pairs)
		Question.Type.COMPLETION: # Completion
			answer_string = completionBlanksToString(question.blanks)
			# Questions built in the creation menu store answers in `answers`, not `blanks`
			if answer_string == "":
				answer_string = answer_delimiter.join(question.answers)
	
	return PackedStringArray([
		question.theme,
		Question.Type.keys()[question.type], # Enum names match the TYPE_MAP keys
		question.question,
		options_string,
		answer_string
	])

# "term:definition;term:definition"
func matchPairsToString(pairs : Array[Question.Pair]) -> String:
	var parts : Array[String] = []
	for pair in pairs:
		if pair.definitions.is_empty():
			printerr("WARNING: MATCH pair '", pair.term, "' has no definition - skipping.")
			continue
		# The loader only supports one definition per term
		parts.append(pair.term + ":" + pair.definitions[0])
	return option_delimiter.join(parts)

# "accepted1/accepted2"
func completionBlanksToString(blanks : Array[Question.Blank]) -> String:
	if blanks.is_empty():
		return ""
	# The loader treats the answer column as the accepted responses of a single blank
	return answer_delimiter.join(blanks[0].blank)

#endregion

#region PARSING
func parseMC(new_question : Question, options_string : String, answer_string : String):
	# Append valid options
	for option in options_string.split(option_delimiter):
		var trimmed : String = option.strip_edges()
		if trimmed != "":
			new_question.options.append(trimmed)
	
	# Append valid answer
	if answer_string != "":
		new_question.answers.append(answer_string)

func parseSA(new_question : Question, answer_string : String):
	# Append valid answers
	for answer in answer_string.split(answer_delimiter):
		var trimmed : String = answer.strip_edges()
		if trimmed != "":
			new_question.answers.append(trimmed)

func parseMATCH(new_question : Question, options_string : String):
	for pair_string in options_string.split(";"):
		# Skip empty pairs
		var trimmed : String = pair_string.strip_edges()
		if trimmed == "":
			continue
		
		# Handle separator
		var sep_index : int = trimmed.find(":")
		if sep_index == -1:
			printerr("WARNING: MATCH pair missing ':' separator: ", trimmed)
			continue
		
		# Create pairs once validations are handled
		var pair : Question.Pair = Question.Pair.new()
		pair.term = trimmed.substr(0, sep_index).strip_edges()
		pair.definitions = [trimmed.substr(sep_index + 1).strip_edges()]
		new_question.pairs.append(pair)

func parseCOMPLETION(new_question : Question, answer_string : String):
	var accepted_responses : Array[String] = []
	
	for answer in answer_string.split(answer_delimiter):
		var trimmed : String = answer.strip_edges()
		if trimmed != "":
			accepted_responses.append(trimmed)
	
	var blank : Question.Blank = Question.Blank.new()
	blank.blank = accepted_responses
	new_question.blanks.append(blank)

#endregion

#region MISC
func printQuestions(questions : Array[Question]):
	for question in questions:
		print(question.question)
		match question.type:
			Question.Type.MC:
				for option in question.options:
					var marker : String = " "
					if question.answers.has(option):
						marker = "*"
					print(" ", marker, " ", option)
			Question.Type.SA:
				print(" Accepted answers: ", question.answers)
			Question.Type.MATCH:
				for pair in question.pairs:
					print(" ", pair.term, " -> ", pair.definitions)
			Question.Type.COMPLETION:
				for blank in question.blanks:
					print( " Accepted: ", blank.blank)
		print("")
#endregion
