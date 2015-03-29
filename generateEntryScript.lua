
assert(require "git-ssh-access")

function die(msg)
	io.stderr:write(msg.."\n")
	os.exit(1)
end

function which(cmd)
	local file = io.popen("which "..cmd, "r")
	local path = assert(file:read())
	file:close()
	return path
end

local scriptTmpl = [[#!%s

package.path = "%s"
package.cpath = "%s"

require "git-ssh-access" {
	upload = "%s",
	receive = "%s",
	...
}]]

local lua = which(arg[-1])
local upload = which "git-upload-pack"
local receive = which "git-receive-pack"
local script = scriptTmpl:format(lua, package.path, package.cpath, upload, receive)

print(script)
