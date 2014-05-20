--[[
	GIT-ACCESS
	Allow other users access to selected repositories.
	==================================================
	This serves as the backend to git-ssh-access, and in theory scripts
	for other access channels. Checks a user's access rights, then
	exec's git-upload-pack or git-receive-pack if appropriate.
	
	Usage:
	require "git-access" {
		"name" [, "name"]+ ,
		repo = "/path/to/repo",
		action = ["push"|"pull"],
		upload = "/path/to/git-upload-pack",
		receive = "/path/to/git-receive-pack",
	}

	Where:
		name
			"name" is one identity of the current operation's user.
			may appear more than once; identities could represent groups.
		/path/to/repo
			path to the current operation's Git repository.
		action
			whether request was to execute git-upload-pack or git-receive-pack.
		/path/to/git-upload-pack
			absolute path to git-upload-pack command
		/path/to/git-receive-pack
			absolute path to git-receive-pack command
--]]

local function die(...)
	print(...)
	os.exit(1)
end

return function(a)
	--sanity-check args
	if #a < 1 then
		die("[git-access]", "Need at least one name.")
	elseif not a.repo then
		die("[git-access]", "Need a repo path specified.")
	elseif a.action ~= "push" and a.action ~= "pull" then
		die("[git-access]", "Unknown action:", a.action)
	elseif not a.upload then
		die("[git-access]", "Need a path to git-upload-pack")
	elseif not a.receive then
		die("[git-access]", "Need a path to git-receive-pack")
	end
end

--[[
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
]]
