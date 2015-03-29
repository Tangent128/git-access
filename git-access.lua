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

local ACCESS_FILE = "/info/git-access"

local posix = require "posix"
local currentUser = posix.getuid()

local function die(...)
	posix.write(2, table.concat({...}, " ") .. "\n")
	os.exit(1)
end

local function debug(...)
	posix.write(2, table.concat({...}, " ") .. "\n")
end

local access = {}
local function selected(matchName)
	for _, name in pairs(access._names) do
		if name == matchName then
			return true
		end
	end
	return false
end

--[[
	ACCESS CONTROL LEVELS
--]]

function access.deny(args)
	die("[git-access]", "Access denied.")
end

function access.ro(args)
	if args.action == "pull" then
		local ok, err = posix.exec(args.upload, args.repo)
		die("[git-access]", err)
	end
	die("[git-access]", "You have read-only access.")
end

function access.rw(args)
	if args.action == "pull" then
		local ok, err = posix.exec(args.upload, args.repo)
		die("[git-access]", err)
	elseif args.action == "push" then
		local ok, err = posix.exec(args.receive, args.repo)
		die("[git-access]", err)
	end
	die("[git-access]", "????", action)
end

--[[
	End Access Control Levels
--]]

local exists = posix.access

local function owns(path)
	local stat = posix.stat(path)
	if stat then
		local fileOwner = stat.uid
		return fileOwner == currentUser
	else
		return false
	end
end

local function loadfile_compat(path, env)
	local chunk, err = loadfile(path, "t", env)
	if not chunk then
		die("[git-access]", "Error reading access rules.")
	end
	if setfenv then
		setfenv(chunk, env)
	end
	return chunk
end

-- check that a path is a valid Git repo, then try to load access file
-- note: a minimal git-repository contains a HEAD,
-- an objects directory, and a refs directory (directories may
-- be empty, but must exist)
-- also confirm that the current user is the owner of the access file,
-- to avoid a confused deputy.
local function tryAccessFile(repo, env)
	local accessPath = repo .. ACCESS_FILE

	if exists(repo .. "/refs")
	and exists(repo .. "/objects")
	and exists(repo .. "/HEAD")
	and owns(accessPath)
	then
		return loadfile_compat(accessPath, env)
	end
	return nil
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
	
	local givenRepoName = a.repo
	a.repo = posix.realpath(a.repo) or die("[git-access]", "Not a git repo:", givenRepoName)
	
	-- setup rule env
	local policy = access.deny
	
	local names = {}
	for i = 1, #a do
		names[a[i]] = a[i]
	end
	
	local env = {}
	for name, func in pairs(access) do
		env[name] = function(user)
			if names[user] then
				policy = func
			end
		end
	end
	
	-- look for info/git-access file
	local rules =
		tryAccessFile(a.repo .. "/.git", env) or
		tryAccessFile(a.repo, env) or
		die("[git-access]", "Not a git repo:", givenRepoName)
	
	-- match against git-access rules
	local ok, err = pcall(rules)
	if not ok then
		die("[git-access]", "Error reading access rules.")
	end

	-- exec command if policy allows
	policy(a)
	
end
