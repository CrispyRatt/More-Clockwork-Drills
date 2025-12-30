fn define(mod_info) {
	mod_info.add(EntityBuilder(
		"AudioSource:VoxelEras",
		"Audio Source",
		"scripts/audio_source.rhai"
	));
}

fn on_render(entity, client_state, egui) {
	let metadata = entity.metadata;
	let sound_name = metadata.get_string("State:Sound");
	let track = metadata.get_string("State:Track");
	let min_distance = metadata.get_f64("State:MinDist");
	let max_distance = metadata.get_f64("State:MaxDist");
	
	// Ensure metadata valid
	if track == () || sound_name == () || min_distance == () || max_distance == () {
		return;
	}

	// Ensure sound valid
	let sound = client_state.get_sound(sound_name);
	if sound == () {
		debug("Couldn't find sound '" + sound_name + "'");
		return;
	}

	// Play (returns true if played this frame)
	sound.play_oneshot_3d(track, entity, min_distance, max_distance);
	()
}

fn on_tick(entity, game_state) {
	if entity.spawn_tick + (game::TICK_RATE / 4) <= game_state.tick {
		let entity_id = entity.id;
		game_state.remove_entity(entity_id);
	}
}

fn spawn_oneshot_3d(sound, track, position, game_state, min_distance, max_distance) {
	let metadata = MetaData();
	metadata.set_string("State:Sound", sound);
	metadata.set_string("State:Track", track);
	metadata.set_f64("State:MinDist", min_distance);
	metadata.set_f64("State:MaxDist", max_distance);

	game_state.spawn_entity(
		game_state.get_entity_prefab("AudioSource:VoxelEras"),
		position,
		metadata
	);
}