fn setup(mod_info, load_info) {
	import "scripts/clockwork/wrought_drill" as wrought_drill;
	import "scripts/clockwork/steel_drill" as steel_drill;

	import "scripts/items" as items;
	
	wrought_drill::define(mod_info);
	steel_drill::define(mod_info);

	items::define(mod_info);

	mod_info.add(TextureBuilder(
		"WroughtDrillEraIcon:BetterMiner",
		"assets/icons/test_icon.png"
	));
	mod_info.add(TextureBuilder(
		"SteelDrillEraIcon:BetterMiner",
		"assets/icons/test_icon.png"
	));
	mod_info.add(TextureBuilder(
		"CarbonSteelCoreEraIcon:BetterMiner",
		"assets/icons/test_icon.png"
	));

	mod_info.add(UnlockBuilder( //defines how recipe is unlocked
		"WroughtDrillEra:BetterMiner",
		"A Better Drill?",
		"Those clockwork drills are nice sure, \nbut now that you have some stronger materials how about we improve them?",
		"WroughtDrillEraIcon:BetterMiner",
	).requires("ClockworkDrill:VoxelEras")
	.craft(WeakItemStack("Concrete:VoxelEras", 4))
	.craft(WeakItemStack("WroughtIronGear:VoxelEras", 2))
	.craft(WeakItemStack("WroughtIronPlate:VoxelEras", 4))
	.unlocks_construct("WroughtDrill:BetterMiner")
	.unlocks_recipe("SmallSteelGear:BetterMiner")
	.unlocks_recipe("CarbonSteelCore:BetterMiner")
	);


	mod_info.add(UnlockBuilder( //defines how recipe is unlocked
		"CarbonSteelCoreEra:BetterMiner",
		"Pushing Clockwork Further!",
		"Now we're getting somewhere!\n It seems like you'll need something stronger than bronze if you wanna push this any further. \nThough I doubt you could assemble those parts by hand...",
		"CarbonSteelCoreEraIcon:BetterMiner",
	).requires("WroughtDrillEra:BetterMiner")
	.requires("CarbonSteel:VoxelEras")
	.craft(WeakItemStack("CarbonSteelPlate:VoxelEras", 2))
	.collect(WeakItemStack("SmallSteelGear:BetterMiner", 6))
	.collect(WeakItemStack("CarbonSteelCore:BetterMiner", 2))
	);

	mod_info.add(UnlockBuilder( //defines how recipe is unlocked
		"SteelDrillEra:BetterMiner",
		"The Ultimate Drill!",
		"Perfect! A clockwork core made of Carbon Steel should be just what you need to build an even more powerful drill!",
		"SteelDrillEraIcon:BetterMiner",
	).requires("CarbonSteelCoreEra:BetterMiner")
	.craft(WeakItemStack("CarbonSteelGear:VoxelEras", 4))
	.craft(WeakItemStack("CarbonSteelPlate:VoxelEras", 8))
	.collect(WeakItemStack("CarbonSteelCore:BetterMiner", 2))
	.collect(WeakItemStack("SmallSteelGear:BetterMiner", 6))
	.unlocks_construct("SteelDrill:BetterMiner")
	);

}