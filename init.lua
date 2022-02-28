
minetest_randomizer = {}

minetest_randomizer.original = {}

minetest_randomizer.shuffled = {}


minetest.register_privilege("randomizerspoilers", {
description = "Allows for the use of the /randomizerspoiler command.",
give_to_singleplayer = false,
give_to_admin = true

})

minetest.register_chatcommand("randomizerspoiler",{
    params = "<node_id>",

    description = "Spoil the drops of the specified node.", 

    privs = {randomizerspoilers=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		if (minetest_randomizer.shuffled[param]) then
			return true, param .. " has the drops of " .. minetest_randomizer.shuffled[param]
		end
	
		return false, "The specified node doesn't exist or hasn't been randomized."
	end,
})

minetest.register_chatcommand("randomizersearch",{
    params = "<node_to_search>",

    description = "Search for the node that drops the items of the specified node.", 

    privs = {randomizerspoilers=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		for i, thing in pairs(minetest_randomizer.shuffled) do
			if (thing == param) then
				return true, i .. " has the drops of " .. thing
			end
		
		end
	
		return false, "The specified node doesn't exist or hasn't been randomized."
	end,
})


minetest.register_chatcommand("randomizersearchforstable",{
    params = "",

    description = "Search and display all nodes that are stable.(Drop themselves)", 

    privs = {randomizerspoilers=true},  -- Require the "privs" privilege to run

    func = function(name, param)
		local stable_nodes = {}
		for i, thing in pairs(minetest_randomizer.shuffled) do
			if (minetest.registered_nodes[i].drop == i) then
				table.insert(stable_nodes,i)
			end
		
		end
		if (#stable_nodes == 0) then
			return false, "This randomization has no stable nodes."
		end
		
		local end_string = ""
		
		for i=1, #stable_nodes do
			end_string = end_string .. stable_nodes[i] .. ","
		end
		
		end_string = string.sub(end_string,1,-2)
		
		return true, end_string
		
	end,
})



minetest.register_on_mods_loaded(function()
	local everything = {}
	
	for i, thing in pairs(minetest.registered_nodes) do
		table.insert(everything,thing.drop or i)
		minetest_randomizer.original[thing.drop or i] = i
	end
	
	math.randomseed(minetest.get_mapgen_setting("seed"))
	
	for i, thing in pairs(minetest.registered_nodes) do
		local rngdex = math.random(1,#everything)
		minetest_randomizer.shuffled[i] = minetest_randomizer.original[everything[rngdex]]
		minetest.override_item(i,{drop=everything[rngdex]})
		table.remove(everything,rngdex)
	end

	minetest_randomizer.original = {} --save up on memory?
end)