fn define(mod_info) {
	mod_info.add(TextureBuilder(
		"SmallSteelGearIcon:BetterMiner",
		"assets/items/SmallSteelGear.png"
	));

	mod_info.add(TextureBuilder(
		"CarbonSteelCoreIcon:BetterMiner",
		"assets/items/CarbonSteelCore.png"
	));
    
	mod_info.add(
		ItemBuilder(
			"SmallSteelGear:BetterMiner",
			"Small Carbon Steel Gear",
			"Tiny gears for tough mechanisms! \nStacks to 128",
			"SmallSteelGearIcon:BetterMiner"
		).stacking_to(128)
	);

	mod_info.add(
		ItemBuilder(
			"CarbonSteelCore:BetterMiner",
			"Carbon Steel Clockwork Core",
			"A more durable clockwork heart. \nStacks to 128",
			"CarbonSteelCoreIcon:BetterMiner"
		).stacking_to(128)
	);

	mod_info.add(
		RecipeBuilder(
			"SmallSteelGear:BetterMiner",
			"Fasten Carbon Steel parts into Small Steel Gear",
			5,
			"SmallSteelGearIcon:BetterMiner"
		).crafted_in("Assembler:VoxelEras")
		.with_input(WeakItemStack("CarbonSteelRing:VoxelEras", 3))
		.with_input(WeakItemStack("CarbonSteelPlate:VoxelEras", 2))
		.with_input(WeakItemStack("CarbonSteelBolt:VoxelEras", 6))
		.with_output(WeakItemStack("SmallSteelGear:BetterMiner", 3))
	);

	mod_info.add(
		RecipeBuilder(
			"CarbonSteelCore:BetterMiner",
			"Form a more durable Clockwork Core",
			3,
			"ClockworkCoreIcon:VoxelEras"
		).crafted_in("Assembler:VoxelEras")
		.with_input(WeakItemStack("SmallSteelGear:BetterMiner", 3))
		.with_input(WeakItemStack("CarbonSteelPlate:VoxelEras", 1))
		.with_output(WeakItemStack("CarbonSteelCore:BetterMiner", 1))
	);

}


