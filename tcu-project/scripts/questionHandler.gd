class_name QuestionHandler
extends Node

## Result of asking a single Question and collecting the player's response.
class QuestionResult:
	## True only when the question was answered fully correctly.
	var correct: bool = false
	## 1.0 = fully correct. For MATCH this can be a fraction (e.g. 0.5 for
	## 2 of 4 pairs matched) in case you want partial credit later.
	var score_fraction: float = 0.0


## --- Context needed to render questions through Dialogue Manager ---
## Call configure() once before handling any questions.
var displayed_name: String = ""
var active_balloon = null
var ui_container: Node = null
var prompter_scene: PackedScene = null


func configure(p_displayed_name: String, p_active_balloon, p_ui_container: Node, p_prompter_scene: PackedScene) -> void:
	displayed_name = p_displayed_name
	active_balloon = p_active_balloon
	ui_container = p_ui_container
	prompter_scene = p_prompter_scene


## Dispatches to the right handler based on question.type.
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
		_:
			printerr("QuestionHandler: unknown question type: ", question.type)
			return QuestionResult.new()


## Multiple choice: show the prompt with each option as a dialogue
## response, then check the picked response text against the answer.
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


## Short answer: show the prompt with no choices, then collect free text
## from a LineEdit and compare (case-insensitive) against every accepted
## answer.
func handleSAQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	lines.append("=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))
	var question_line = await question_resource.get_next_dialogue_line("question")
	await active_balloon.show_external_text_line(question_line, question_resource)

	# Hide the balloon while the prompter is up so a stray click/keypress
	# can't reach its still-active gui_input handler (see _promptForText).
	active_balloon.hide()
	var response_text := await _promptForText("Type your answer...")

	for accepted in question.answers:
		if response_text.strip_edges().to_lower() == accepted.strip_edges().to_lower():
			result.correct = true
			break

	result.score_fraction = 1.0 if result.correct else 0.0
	active_balloon.show()
	return result


## Completion: same free-text flow as SA, checked against the accepted
## answers for the question's single blank.
func handleCOMPLETIONQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	var lines: PackedStringArray = []
	lines.append("~ question")
	lines.append(displayed_name + ": %s" % question.question.replace("\"", "'"))
	lines.append("=> END")
	var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))
	var question_line = await question_resource.get_next_dialogue_line("question")
	await active_balloon.show_external_text_line(question_line, question_resource)

	# Hide the balloon while the prompter is up so a stray click/keypress
	# can't reach its still-active gui_input handler (see _promptForText).
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


## Match: no dedicated drag-and-drop UI exists yet, so this asks the player
## to match each term one at a time, MC-style, against all definitions from
## the question (shuffled). Adjust freely if you build a real matching UI.
func handleMatchQuestion(question: Question) -> QuestionResult:
	var result := QuestionResult.new()

	if question.pairs.is_empty():
		result.correct = true
		result.score_fraction = 1.0
		return result

	var all_definitions: Array[String] = []
	for pair in question.pairs:
		if pair.definitions.size() > 0:
			all_definitions.append(pair.definitions[0])

	var correct_count := 0

	for pair in question.pairs:
		var shuffled_definitions := all_definitions.duplicate()
		shuffled_definitions.shuffle()

		var lines: PackedStringArray = []
		lines.append("~ question")
		lines.append(displayed_name + ": Match \"%s\" with its definition." % pair.term.replace("\"", "'"))
		for definition in shuffled_definitions:
			lines.append("- %s" % definition.replace("\"", "'"))
			lines.append("\t=> END")
		var question_resource = DialogueManager.create_resource_from_text("\n".join(lines))

		var question_line = await question_resource.get_next_dialogue_line("question")
		var response = await active_balloon.show_external_line(question_line, question_resource)

		var correct_definition: String = pair.definitions[0] if pair.definitions.size() > 0 else ""
		if response.text == correct_definition.replace("\"", "'"):
			correct_count += 1

	result.score_fraction = float(correct_count) / float(question.pairs.size())
	result.correct = correct_count == question.pairs.size()
	return result


## Shared helper for SA/COMPLETION: instantiates the GenericPrompter scene
## in ui_container, waits for the player to submit an answer (Enter or the
## Done button), then removes it and returns the typed text.
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
