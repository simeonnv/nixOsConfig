# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{...}: {
  flake.homeModules.yt-dlp = {config, ...}: {
    programs.yt-dlp = {
      enable = true;
      settings = {
        output = "'${config.home.homeDirectory}/Downloads/yt-dlp/%(uploader)s/%(title)s [%(id)s].%(ext)s'";
        embed-metadata = true;
        embed-thumbnail = true;
        embed-chapters = true;
        embed-subs = true;
        sub-langs = "en.*";
        merge-output-format = "mkv";
        no-mtime = true;
      };
    };

    home.shellAliases = {
      yta = "yt-dlp -x --audio-format mp3 --audio-quality 0";
      ytv = "yt-dlp -f 'bv*[height<=1080]+ba/b[height<=1080]'";
      ytp = "yt-dlp -o \"$HOME/Downloads/yt-dlp/%(playlist_title)s/%(playlist_index)03d - %(title)s.%(ext)s\"";
    };
  };
}
