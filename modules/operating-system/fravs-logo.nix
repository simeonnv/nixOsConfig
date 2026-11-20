# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT
{
  flake.lib.fravsLogo = pkgs: let
    font = "${pkgs.ultimate-oldschool-pc-font-pack}/share/fonts/truetype/MxPlus_IBM_VGA_8x16.ttf";
  in
    pkgs.runCommand "fravs-logo" {nativeBuildInputs = [pkgs.imagemagick];} ''
      mkdir -p $out

      magick -density 72 -background none -fill '#c4a7e7' -font ${font} -pointsize 16 +antialias \
        label:']T[' -trim +repage logo-tight.png
      magick logo-tight.png -gravity center -background none -extent 24x24 logo-base.png

      magick logo-base.png -filter point -resize 2000% $out/logo.png
      magick logo-base.png -filter point -resize 800% $out/favicon.png

      pixelSvg() {
        echo "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 $(magick identify -format '%w %h' $1)\" shape-rendering=\"crispEdges\" fill=\"#c4a7e7\">"
        magick $1 -alpha extract txt:- \
          | awk -F'[,: ]+' 'NR > 1 && $0 !~ /#000000/ {printf "<rect x=\"%s\" y=\"%s\" width=\"1\" height=\"1\"/>", $1, $2}'
        echo '</svg>'
      }
      pixelSvg logo-tight.png > $out/logo.svg
      pixelSvg logo-base.png > $out/favicon.svg
    '';
}
