import "scripts/audio_source" as audio;

const MAX_ENERGY = game::TICK_RATE * 96;
const ENERGY_PER_INTERACT = game::TICK_RATE * 12;
const INTERACT_DELAY = game::TICK_RATE / 4;
const PROGRESS_TO_MINE = game::TICK_RATE * 6;

fn define(mod_info) {
	
	mod_info.add(TextureBuilder(
        "WroughtDrillIcon:BetterMiner",
        "assets/textures/WroughtDrillSideOffAnim.png",
    ));

	mod_info.add(TextureBuilder(
        "ConcreteOutputBlock:BetterMiner",
        "assets/textures/ConcreteOutput.png"
    ));

	define_variants(mod_info);

	let default_place_variant = WeakVoxelVariant("WroughtDrill:BetterMiner", voxel::ROT_UP)
		.add_state("State:LastInteracted", metadata::U64(0))
		.add_state("State:ClockworkEnergy", metadata::U64(0))
		.add_state("State:Progress", metadata::U64(0))
		.add_state("State:Inventory", metadata::Inventory(0));
	
	mod_info.add(
		ConstructBuilder(
			"WroughtDrill:BetterMiner",
            "Wrought Iron Drill",
            "An upgraded method of drilling without your bare hands.\nOutputs automatically to the top.",
            "Machines",
            "WroughtDrillIcon:BetterMiner",
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
		.priority(2)
		.cost(WeakItemStack("Concrete:VoxelEras", 4))
		.cost(WeakItemStack("WroughtIronGear:VoxelEras", 2))
		.cost(WeakItemStack("WroughtIronPlate:VoxelEras", 4))
	);

	mod_info.add(SoundBuilder(
		"WroughtDrillProgress1:BetterMiner",
		"Wrought Drill Progress",
		"assets/sounds/WroughtDrillProgress1.mp3"
	));

	mod_info.add(SoundBuilder(
		"WroughtDrillProgress2:BetterMiner",
		"Wrought Drill Progress",
		"assets/sounds/WroughtDrillProgress2.mp3"
	));

	mod_info.add(SoundBuilder(
		"WroughtDrillTick:BetterMiner",
		"Wrought Drill Tick",
		"assets/sounds/WroughtDrillTick.mp3"
	));
}

private fn define_variants(mod_info) {
	mod_info.add(TextureBuilder(
        "WroughtDrillOffBlock:BetterMiner",
        "assets/textures/WroughtDrillSideOffAnim.png"
    ));

	// Off
	mod_info.add(
		VoxelBuilder(
			"WroughtDrill:BetterMiner",
			"Wrought Drill (Off)",
			"scripts/clockwork/wrought_drill.rhai"
		).model(SolidVoxelModel(
			"ConcreteOutputBlock:BetterMiner",
			"WroughtDrillOffBlock:BetterMiner",
			"OakWoodPlankBlock:VoxelEras"
		))
		.pipette("WroughtDrill:BetterMiner")
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
			"WroughtDrillPower" + level + "Block:BetterMiner",
			"assets/textures/WroughtDrillPower" + level + "Anim.png"
		));

		mod_info.add(
			VoxelBuilder(
				"WroughtDrillPower" + level + ":BetterMiner",
				"Wrought Drill (Running)",
				"scripts/clockwork/wrought_drill.rhai"
			).model(SolidVoxelModel(
				"ConcreteOutputBlock:BetterMiner",
				"WroughtDrillPower" + level + "Block:BetterMiner",
				"OakWoodPlankBlock:VoxelEras"
			))
			.pipette("WroughtDrill:BetterMiner")
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
        "WroughtDrillStalledBlock:BetterMiner",
        "assets/textures/WroughtDrillSideStuckAnim.png"
    ));

	mod_info.add(
		VoxelBuilder(
			"WroughtDrillStuck:BetterMiner",
			"Wrought Drill (Stalled!)",
			"scripts/clockwork/wrought_drill.rhai"
		).model(SolidVoxelModel(
			"ConcreteOutputBlock:BetterMiner",
			"WroughtDrillStalledBlock:BetterMiner",
			"OakWoodPlankBlock:VoxelEras"
		))
		.pipette("WroughtDrill:BetterMiner")
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
		game_state.drop(WeakItemStack("Concrete:VoxelEras", 4), location);
		game_state.drop(WeakItemStack("WroughtIronGear:VoxelEras", 2), location);
		game_state.drop(WeakItemStack("WroughtIronPlate:VoxelEras", 4), location);
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
	if energy == 0 && progress == 0 && voxel.prefab.identifier == "WroughtDrillOff:BetterMiner" {
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
			"WroughtDrillTick:BetterMiner",
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
			"IronOre:VoxelEras" => WeakItemStack("IronOre:VoxelEras", 2),
			"CopperOre:VoxelEras" => WeakItemStack("CopperOre:VoxelEras", 2),
			"TinOre:VoxelEras" => WeakItemStack("TinOre:VoxelEras", 2),
			"CoalOre:VoxelEras" => WeakItemStack("Coal:VoxelEras", 2),
			"Floor:VoxelEras" => WeakItemStack("Stone:VoxelEras", 4),
			"Stone:VoxelEras" => WeakItemStack("Stone:VoxelEras", 2),
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
						"WroughtDrillProgress1:BetterMiner"
					} else {
						"WroughtDrillProgress2:BetterMiner"
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
							"WroughtDrillProgress1:BetterMiner"
						} else {
							"WroughtDrillProgress2:BetterMiner"
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
				"WroughtDrillStuck:BetterMiner"
			} else if was_running {
				"WroughtDrillPower" + energy / (global::MAX_ENERGY / 4) + ":BetterMiner"
			} else {
				"WroughtDrill:BetterMiner"
			}
		).get_variant(voxel.rotation, new_state)
	);
}