import "scripts/audio_source" as audio;

const MAX_ENERGY = game::TICK_RATE * 96;
const ENERGY_PER_INTERACT = game::TICK_RATE * 12;
const INTERACT_DELAY = game::TICK_RATE / 4;
const PROGRESS_TO_MINE = game::TICK_RATE * 6;

fn define(mod_info) {
	
	mod_info.add(TextureBuilder(
        "SteelDrillIcon:BetterMiner",
        "assets/textures/SteelDrillSideOffAnim.png",
    ));

	mod_info.add(TextureBuilder(
        "SteelOutputBlock:BetterMiner",
        "assets/textures/SteelOutput.png"
    ));

	define_variants(mod_info);

	let default_place_variant = WeakVoxelVariant("SteelDrill:BetterMiner", voxel::ROT_UP)
		.add_state("State:LastInteracted", metadata::U64(0))
		.add_state("State:ClockworkEnergy", metadata::U64(0))
		.add_state("State:Progress", metadata::U64(0))
		.add_state("State:Inventory", metadata::Inventory(0));
	
	mod_info.add(
		ConstructBuilder(
			"SteelDrill:BetterMiner",
            "Carbon Steel Drill",
            "An upgraded method of drilling without your bare hands.\nOutputs automatically to the top.",
            "Machines",
            "SteelDrillIcon:BetterMiner",
			construct::ROT_NONE
		).variant(
			ConstructVariantBuilder(voxel::ROT_UP)
				.place(
					0, 0, 0,
					default_place_variant
				).require(
					0, -1, 0,
					WeakConstructRequirement(["Ore:VoxelEras"])
				).require(
					0, -1, 0,
					WeakConstructRequirement("Stone:VoxelEras")
				)
		)
		.priority(3)
		.cost(WeakItemStack("CarbonSteelGear:VoxelEras", 4))
		.cost(WeakItemStack("CarbonSteelPlate:VoxelEras", 8))
		.cost(WeakItemStack("CarbonSteelCore:BetterMiner", 2))
		.cost(WeakItemStack("SmallSteelGear:BetterMiner", 6))
	);

	mod_info.add(SoundBuilder(
		"SteelDrillProgress1:BetterMiner",
		"Steel Drill Progress",
		"assets/sounds/SteelDrillProgress1.mp3"
	));

	mod_info.add(SoundBuilder(
		"SteelDrillProgress2:BetterMiner",
		"Steel Drill Progress",
		"assets/sounds/SteelDrillProgress2.mp3"
	));

	mod_info.add(SoundBuilder(
		"SteelDrillTick:BetterMiner",
		"Steel Drill Tick",
		"assets/sounds/SteelDrillTick.mp3"
	));
}

private fn define_variants(mod_info) {
	mod_info.add(TextureBuilder(
        "SteelDrillOffBlock:BetterMiner",
        "assets/textures/SteelDrillSideOffAnim.png"
    ));

	// Off
	mod_info.add(
		VoxelBuilder(
			"SteelDrill:BetterMiner",
			"Steel Drill (Off)",
			"scripts/clockwork/steel_drill.rhai"
		).model(SolidVoxelModel(
			"SteelOutputBlock:BetterMiner",
			"SteelDrillOffBlock:BetterMiner",
			"OakWoodPlankBlock:VoxelEras"
		))
		.pipette("SteelDrill:BetterMiner")
		.break_rate(voxel::BREAK_RATE_MACHINE)
		.tag("Solid:VoxelEras")
		.does_break()
		.does_tick()
		.does_interact()
		.does_message()
	);

	// Running (0-3 power)
	for level in 0..4 {
		mod_info.add(TextureBuilder(
			"SteelDrillPower" + level + "Block:BetterMiner",
			"assets/textures/SteelDrillPower" + level + "Anim.png"
		));

		mod_info.add(
			VoxelBuilder(
				"SteelDrillPower" + level + ":BetterMiner",
				"Steel Drill (Running)",
				"scripts/clockwork/steel_drill.rhai"
			).model(SolidVoxelModel(
				"SteelOutputBlock:BetterMiner",
				"SteelDrillPower" + level + "Block:BetterMiner",
				"OakWoodPlankBlock:VoxelEras"
			))
			.pipette("SteelDrill:BetterMiner")
			.break_rate(voxel::BREAK_RATE_MACHINE)
			.tag("Solid:VoxelEras")
			.does_break()
			.does_tick()
			.does_interact()
			.does_message()
		);
	}

	// Stalled
	mod_info.add(TextureBuilder(
        "SteelDrillStalledBlock:BetterMiner",
        "assets/textures/SteelDrillSideStuckAnim.png"
    ));

	mod_info.add(
		VoxelBuilder(
			"SteelDrillStuck:BetterMiner",
			"Steel Drill (Stalled!)",
			"scripts/clockwork/steel_drill.rhai"
		).model(SolidVoxelModel(
			"SteelOutputBlock:BetterMiner",
			"SteelDrillStalledBlock:BetterMiner",
			"OakWoodPlankBlock:VoxelEras"
		))
		.pipette("SteelDrill:BetterMiner")
		.break_rate(voxel::BREAK_RATE_MACHINE)
		.tag("Solid:VoxelEras")
		.does_break()
		.does_tick()
		.does_interact()
		.does_message()
	);
}

fn on_break(voxel, location, target, entity, game_state) {
	if location == target {
		game_state.drop(WeakItemStack("CarbonSteelPlate:VoxelEras", 8), location);
		game_state.drop(WeakItemStack("CarbonSteelGear:VoxelEras", 4), location);
		game_state.drop(WeakItemStack("CarbonSteelCore:BetterMiner", 2), location);
		game_state.drop(WeakItemStack("SmallSteelGear:BetterMiner", 6), location);
	}

	event::ACCEPT
}

fn on_interact(voxel, location, entity, game_state) {
	if game_state.tick < voxel.metadata.get_u64("State:LastInteracted") + INTERACT_DELAY {
		return event::CANCEL;
	}

	let stored_energy = voxel.metadata.get_u64("State:ClockworkEnergy");
	if stored_energy + global::ENERGY_PER_INTERACT > global::MAX_ENERGY {
		return event::CANCEL;
	}

	let new_state = voxel.metadata;
	new_state.set_u64("State:LastInteracted", game_state.tick);
	new_state.set_u64("State:ClockworkEnergy", stored_energy + global::ENERGY_PER_INTERACT);

	game_state.set_voxel(
		location,
		voxel.get_variant(new_state)
	);

	event::ACCEPT
}

fn on_message(voxel, location, type, message, game_state) {
	if type != "CLOCKWORK" { return event::CANCEL; }
	let energy = message;

	let stored_energy = voxel.metadata.get_u64("State:ClockworkEnergy");
	if stored_energy + energy > global::MAX_ENERGY / 3 {
		return event::CANCEL;
	}

	let new_state = voxel.metadata;
	new_state.set_u64("State:ClockworkEnergy", stored_energy + energy);

	game_state.set_voxel(
		location,
		voxel.get_variant(new_state)
	);

	event::ACCEPT
}

fn on_tick(voxel, location, game_state) {
	let energy = voxel.metadata.get_u64("State:ClockworkEnergy");
	let progress = voxel.metadata.get_u64("State:Progress");

	// If this isn't doing anything and is the right type, bail
	if energy == 0 && progress == 0 && voxel.prefab.identifier == "SteelDrillOff:BetterMiner" {
		return;
	}

	let was_running = false;
	if progress < global::PROGRESS_TO_MINE {
		if energy > 0 {
			energy -= 1;
			progress += 1;
			was_running = true;
		}
	}

	if was_running && progress % (game::TICK_RATE / 4) == 3 {
		audio::spawn_oneshot_3d(
			"SteelDrillTick:BetterMiner",
			"Machine:VoxelEras",
			Vec3(location.x.to_float() + 0.5, location.y.to_float() + 0.5, location.z.to_float() + 0.5),
			game_state,
			1.,
			10.
		);
	}

	let stalled = false;
	if progress >= global::PROGRESS_TO_MINE {
		let below = game_state.get_voxel(location.down());

		let mining_drop = switch below.prefab.identifier.to_string() {
			"IronOre:VoxelEras" => WeakItemStack("IronOre:VoxelEras", 4),
			"CopperOre:VoxelEras" => WeakItemStack("CopperOre:VoxelEras", 4),
			"TinOre:VoxelEras" => WeakItemStack("TinOre:VoxelEras", 4),
			"CoalOre:VoxelEras" => WeakItemStack("Coal:VoxelEras", 4),
			"Floor:VoxelEras" => WeakItemStack("Stone:VoxelEras", 6),
			"Stone:VoxelEras" => WeakItemStack("Stone:VoxelEras", 4),
			_ => {
				stalled = true;
				()
			}
		};

		if mining_drop != () {
			// Try inserting into the bottom side of the block above
			if game_state.try_insert(location.up(), voxel::SIDE_BOTTOM, mining_drop) {
				game_state.increment_statistic("Craft", mining_drop.identifier, mining_drop.quantity);

				// Success!
				audio::spawn_oneshot_3d(
					if game_state.random_bool(0.5) {
						"SteelDrillProgress1:BetterMiner"
					} else {
						"SteelDrillProgress2:BetterMiner"
					},
					"Machine:VoxelEras",
					Vec3(location.x.to_float() + 0.5, location.y.to_float() + 0.5, location.z.to_float() + 0.5),
					game_state,
					1.,
					35.
				);
			} else { 
				let above = game_state.get_voxel(location.up());
				if above.prefab.identifier == "Air:VoxelEras" {
					game_state.increment_statistic("Craft", mining_drop.identifier, mining_drop.quantity);
				
					game_state.drop(mining_drop, location.up());
					audio::spawn_oneshot_3d(
						if game_state.random_bool(0.5) {
							"SteelDrillProgress1:BetterMiner"
						} else {
							"SteelDrillProgress2:BetterMiner"
						},
						"Machine:VoxelEras",
						Vec3(location.x.to_float() + 0.5, location.y.to_float() + 0.5, location.z.to_float() + 0.5),
						game_state,
						1.,
						35.
					);
				} else {
					stalled = true;
				}
			}
		}

		if !stalled {
			progress -= global::PROGRESS_TO_MINE;
		}
	}

	let new_state = voxel.metadata;
	new_state.set_u64("State:Progress", progress);
	new_state.set_u64("State:ClockworkEnergy", energy);

	game_state.set_voxel(
		location,
		game_state.get_voxel_prefab(
			if stalled {
				"SteelDrillStuck:BetterMiner"
			} else if was_running {
				"SteelDrillPower" + energy / (global::MAX_ENERGY / 4) + ":BetterMiner"
			} else {
				"SteelDrill:BetterMiner"
			}
		).get_variant(voxel.rotation, new_state)
	);
}