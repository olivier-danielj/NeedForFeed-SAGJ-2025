class_name Need

enum Type {HUNGRY, BORED, LOVE, EEP}
enum Action {NONE, WARN, PANIC, CALM}

const mid_min = 40
const high_min = 80

static func Act(x : int) -> Action:
	if x >= high_min:
		return Action.PANIC
	if x >= mid_min:
		return Action.WARN
	return Action.NONE
