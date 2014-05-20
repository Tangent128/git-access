--[[
	GIT-SSH-ACCESS
	Allow SSH keys access to selected repositories.
	===============================================
	This is activated from an SSH-forced command, and passed a list of
	user roles associated with a key. Checks a user's access rights
	against the $SSH_ORIGINAL_COMMAND environment variable.
	
	A wrapper script is needed to ensure that paths are set safely.
	
	Usage:
	require "git-ssh-access" {
		"name" [, "name"]+ ,
		upload = "/path/to/git-upload-pack",
		receive = "/path/to/git-receive-pack",
	}

	Where:
		name
			"name" is one identity of the current key.
			may appear more than once; identities could represent groups.
		/path/to/git-upload-pack
			absolute path to git-upload-pack command
		/path/to/git-upload-pack
			absolute path to git-receive-pack command
--]]

local function die(...)
	print(...)
	os.exit(1)
end

return function(a)
	--sanity-check args
	if #a < 1 then
		die("[git-ssh-access]", "Need at least one name.")
	end
	
	--parse command
	local cmd = os.getenv("SSH_ORIGINAL_COMMAND")
	
	die("OIC:", cmd)
end
