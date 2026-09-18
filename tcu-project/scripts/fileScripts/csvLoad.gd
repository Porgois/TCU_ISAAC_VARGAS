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

#region BASICS
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
	
	for answer in answer_string.split("/"):
		# Only append valid accepted responses (not empty)
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
