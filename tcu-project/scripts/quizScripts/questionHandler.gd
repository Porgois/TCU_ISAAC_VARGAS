class_name QuestionHandler
extends Node

var match_environment_scene: PackedScene = preload("res://scenes/ui/matchUI/matchEnvironment.tscn")

# Result of asking a single Question and collecting the player's response
class QuestionResult:
	var correct: bool = false
	# For partial scores
	var score_fraction: float = 0.0

# Dialogue Manager question render context
var displayed_name: String = ""
var active_balloon = null
var ui_container: Node = null
var prompter_scene: PackedScene = null

func configure(p_displayed_name: String, p_active_balloon, p_ui_container: Node, p_prompter_scene: PackedScene, p_match_environment_scene: PackedScene = null) -> void:
	displayed_name = p_displayed_name
	active_balloon = p_active_balloon
	ui_container = p_ui_container
	prompter_scene = p_prompter_scene
	match_environment_scene = p_match_environment_scene

# Dispatches to the right handler based on question.type
func handleQuestion(question: Question) -> QuestionResult:
	match question.type:
		Question.Type.MC:
			return await handleMCQuestion(question)
		Question.Type.SA:
			return await handleSAQuestion(question)
		Question.Type.MATCH:
			return await handleMatchQuestion(question)
		Question.Type.COMPLETION:
			return await handleCOMPLETIONQuestion(question)
		_: # Unkown
			printerr("QuestionHandler: unknown question type: ", question.type)
			return QuestionResult.new()

# Multiple choice
func handleMCQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	for option in question.options:
		lines.append("- %s" % option.replace("\"", "'"))
		lines.append("\t=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))

	var question_line = await question_resource.get_next_dialogue_line("question")
	var response = await active_balloon.show_external_line(question_line, question_resource)

	var correct_answer: String = question.answers[0] if question.answers.size() > 0 else ""
	result.correct = response.text == correct_answer.replace("\"", "'")
	result.score_fraction = 1.0 if result.correct else 0.0
	return result

# Short answer (case-insensitive)
func handleSAQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	lines.append("=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))
	var question_line = await question_resource.get_next_dialogue_line("question")
	await active_balloon.show_external_text_line(question_line, question_resource)

	# Hide the balloon while the prompter is up so a stray click/keypress can't reach its still-active
	active_balloon.hide()
	var response_text := await _promptForText("Type your answer...")

	for accepted in question.answers:
		if response_text.strip_edges().to_lower() == accepted.strip_edges().to_lower():
			result.correct = true
			break

	result.score_fraction = 1.0 if result.correct else 0.0
	active_balloon.show()
	return result

# Completion
func handleCOMPLETIONQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	lines.append("=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))
	var question_line = await question_resource.get_next_dialogue_line("question")
	await active_balloon.show_external_text_line(question_line, question_resource)

	# Hide the balloon while the prompter is up so a stray click/keypress can't reach its still-active
	active_balloon.hide()
	var response_text := await _promptForText("Fill in the blank...")

	if question.blanks.size() > 0:
		for accepted in question.blanks[0].blank:
			if response_text.strip_edges().to_lower() == accepted.strip_edges().to_lower():
				result.correct = true
				break

	result.score_fraction = 1.0 if result.correct else 0.0
	active_balloon.show()
	return result

# Match (uses custom match environment)
func handleMatchQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	if question.pairs.is_empty():
		result.correct = true
		result.score_fraction = 1.0
		return result

	if match_environment_scene == null or ui_container == null:
		printerr("QuestionHandler: no match_environment_scene/ui_container configured for MATCH questions.")
		return result

	# Show the prompt text through the balloon, same as SA/COMPLETION
	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	lines.append("=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))
	var question_line = await question_resource.get_next_dialogue_line("question")
	await active_balloon.show_external_text_line(question_line, question_resource)

	active_balloon.hide()

	var match_environment: MatchEnvironment = match_environment_scene.instantiate()
	ui_container.add_child(match_environment)
	match_environment.configureFromPairs(question.pairs)

	await match_environment.match_confirmed
	var scored: Dictionary = match_environment.collectResults()
	match_environment.queue_free()

	active_balloon.show()

	result.score_fraction = float(scored.correct) / float(scored.total) if scored.total > 0 else 1.0
	result.correct = scored.correct == scored.total
	return result

# SA/COMPLETION helper
func _promptForText(placeholder: String = "Type your answer...") -> String:
	if prompter_scene == null or ui_container == null:
		printerr("QuestionHandler: no prompter_scene/ui_container configured for free-text questions.")
		return ""

	var prompter := prompter_scene.instantiate()
	ui_container.add_child(prompter)
	prompter.reset(placeholder)

	var response_text: String = await prompter.input_saved

	prompter.queue_free()
	return response_text
