#!/usr/bin/env lua

--[[
	GIT-ACCESS
	Allow other users access to selected repositories.
	==================================================
	This serves as the backend to git-ssh-access, and in theory scripts
	for other access channels. Checks a user's access rights, then
	executes git-upload-pack or git-receive-pack if appropriate.
	
	Usage:
	git-access [-u name]+ -g repo [--upload-pack | --receive-pack]
	
	Where:
		-u name
			"name" is one identity of the current operation's user.
			may appear more than once; identities could represent groups.
		-g repo
			path to the current operation's Git repositiory.
		--upload-pack
			request was to execute git-upload-pack.
		--receive-pack
			request was to execute git-receive-pack.
--]]

-- parse options
local argv = {...}
local names = {}
local repo = nil
local mode = nil

local i = 1
local function popArg()
	if not argv[i + 1] then
		print([[Expected argument after "]]..argv[i]..[["]])
		os.exit(1)
	end
	i = i + 1
	return argv[i]
end
local function onlyOne(existing)
	if existing then
		print([[Argument "]]..argv[i]..[[" can only appear once or conflicts with previous arguments.]])
		os.exit(1)
	end
end

while i <= #argv do
	local arg = argv[i]
	
	if arg == "-u" then
		names[#names + 1] = popArg()
	elseif arg == "-g" then
		onlyOne(repo)
		repo = popArg()
	elseif arg == "--upload-pack" then
		onlyOne(mode)
		mode = "pull"
	elseif arg == "--receive-pack" then
		onlyOne(mode)
		mode = "push"
	else
		print([[Unknown switch "]]..argv[i]..[["]])
		os.exit(1)
	end
	
	i = i + 1
end

if not (repo and mode) then
	print("Both repo and mode need to be specified.")
	os.exit(1)
end

print "git-access stub is satisfied"
print(#names, names[1], names[2], names[3])
print("repo:", repo)
print("mode:", mode)
