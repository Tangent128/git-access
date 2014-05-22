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

local posix = require "posix"

local function die(...)
	posix.write(2, table.concat({...}, " ") .. "\n")
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
	
	die("git-access stub is satisfied\n",
	#a, a[1] or "", a[2] or "", a[3] or "", "\n",
	"repo:", a.repo, "\n",
	"mode:", a.action)
	
	--look for info/git-access file
	
	--match against git-access rules

	-- exec correct command
	
end
