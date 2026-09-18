# Discord rich presence for helix (https://github.com/Ciflire/presence.hx).
# Not packaged in nhx, so built here with nhx's native-plugin builder.
{
  buildHelixPluginWithNative,
  fetchFromGitHub,
  lib,
}:
buildHelixPluginWithNative (finalAttrs: {
  pname = "presence.hx";
  version = "0-unstable-2025-08-07";
  # cog.scm declares package-name 'helix-discord-rpc, so that is the cogs dir
  # and the require path: helix-discord-rpc/helix-discord-rpc.scm
  cogName = "helix-discord-rpc";
  updateVersion = "branch";

  src = fetchFromGitHub {
    owner = "Ciflire";
    repo = finalAttrs.pname;
    rev = "5b5f134c30c3a3d9a6f3565e8cc56973230bc7ef";
    hash = "sha256-L+fExKl4X1BHi+BIKHgBPtqyHHjqAc0qwyvCq8c0B0E=";
  };

  cargoHash = "sha256-YnAQ1NFP3hEV/nNK/L8TGpOgqXTU/40WpFbFd5kHizA=";

  postPatch = ''
    # upstream passes the *screen* cursor column and subtracts a guessed
    # gutter width; our .scm passes the real document column instead
    substituteInPlace src/discord_rpc.rs \
      --replace-fail '&(col - 6).to_string()' '&col.to_string()'

    # files without an extension (Makefile, LICENSE, ...) panic inside the
    # dylib and take helix down with them
    substituteInPlace src/assets.rs \
      --replace-fail \
        'let extension = Path::new(&filename).extension().unwrap().to_str().unwrap();' \
        'let extension = Path::new(&filename).extension().and_then(|e| e.to_str()).unwrap_or("");'

    # real line/col + update on cursor movement, see the file for details
    cp ${./helix-discord-rpc.scm} helix-discord-rpc.scm
  '';

  doCheck = false;

  meta = {
    description = "Discord rich presence plugin for Helix";
    homepage = "https://github.com/Ciflire/presence.hx";
    license = lib.licenses.mit;
  };
})
