extends Node

@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")

var stored_receptors: Dictionary[int, Array]

func add_receptor(strum_line_idx: int):
	if stored_receptors.has(strum_line_idx) and stored_receptors[strum_line_idx].size() > 0:
		var receptor = stored_receptors[strum_line_idx].pop_front()
		chart_source.chart.strum_lines[strum_line_idx].receptors.append(receptor)
	else:
		chart_source.chart.strum_lines[strum_line_idx].receptors.append(Receptor.new())
	get_parent().strum_line_changed.emit(strum_line_idx)

func remove_receptor(strum_line_idx: int):
	if !stored_receptors.has(strum_line_idx):
		stored_receptors[strum_line_idx] = []
	var receptor = chart_source.chart.strum_lines[strum_line_idx].receptors.pop_back()
	stored_receptors[strum_line_idx].insert(0, receptor)
	get_parent().strum_line_changed.emit(strum_line_idx)

func set_cpu(strum_line_idx: int, cpu: bool):
	chart_source.chart.strum_lines[strum_line_idx].cpu = cpu
