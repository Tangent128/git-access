git-access
==========

A lightweight access-control script for Git repositories via SSH.

### Example

Put lines like the following into Danielle's `.ssh/authorized_keys`:

     command="/path/to/git-access/entry.lua alice sharedGroup" ssh-rsa AAAAA....
     command="/path/to/git-access/entry.lua bob sharedGroup" ssh-rsa AAAAB....
     command="/path/to/git-access/entry.lua carol anotherGroup" ssh-rsa AAAAC....

Then in a Git repository owned by Danielle, in a `.git/info/git-access` file:

	 rw "carol"
     ro "sharedGroup"

Now Alice, Bob, and Carol can:

     git clone danielle@host.server.tld:path/to/repo

With Carol additionally able to push changes back into Danielle's repository.

## Security

I can't think of any ways this script would directly allow running
commands besides git-recieve-pack and git-upload-pack, but that doesn't
mean they don't exist.

However, any user with push rights can trigger the associated git hooks,
which raises a concern if they can (through other means) write to a
location that the git-access user can read.

I try to mitigate that by requiring that the git-access file be owned by
the git-access user, hopefully preventing creating a "fake repository".

Some error messages may leak the existence or nonexistence of a given
repository, even if access is denied. I will probably make them more
vague in the future.

In any case, it is **highly** recommended to create a dedicated git user.

## Generating the entry script

For security, the script used as the SSH forced command should have
all paths be absolute. As these differ from OS to OS, use `generateEntryScript.lua`
to generate the entry script.

     lua5.2 generateEntryScript.lua > /path/to/entry.lua
     chmod +x /path/to/entry.lua

To work, generateEntryScript.lua will need luaposix, Git, and git-access
itself to be on the appropriate paths.
