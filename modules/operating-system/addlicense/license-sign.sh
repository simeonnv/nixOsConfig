holder="Simeon Vangelov"
license=""
year=""
check=0

usage() {
  echo "usage: license-sign [-l spdx-id] [-c holder] [-y year] [--check]"
}

fail() {
  echo "license-sign: $*" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    -l | --license)
      [ $# -ge 2 ] || fail "missing value for $1"
      license="$2"
      shift 2
      ;;
    -c | --holder)
      [ $# -ge 2 ] || fail "missing value for $1"
      holder="$2"
      shift 2
      ;;
    -y | --year)
      [ $# -ge 2 ] || fail "missing value for $1"
      year="$2"
      shift 2
      ;;
    --check)
      check=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

root="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "not inside a git repository"
cd "$root"

shopt -s nullglob nocaseglob
candidates=(LICENSE* LICENCE* COPYING* UNLICENSE*)
shopt -u nullglob nocaseglob

declare -A license_files=()
for file in "${candidates[@]}"; do
  if [ -f "$file" ]; then
    license_files["$file"]=1
  fi
done

if [ -z "$license" ]; then
  [ "${#license_files[@]}" -gt 0 ] || fail "no license file found in $root, pass -l <spdx-id>"

  ids=()
  for file in "${!license_files[@]}"; do
    id="$(askalono --format json id "$file" 2>/dev/null | jq -r '.result.license.name // empty' 2>/dev/null)" || id=""
    [ -n "$id" ] || fail "could not identify the license in $file, pass -l <spdx-id>"
    ids+=("$id")
  done

  mapfile -t ids < <(printf '%s\n' "${ids[@]}" | sort -u)
  license="${ids[0]}"
  for id in "${ids[@]:1}"; do
    license="$license OR $id"
  done
fi

files=()
while IFS= read -r -d '' file; do
  if [ ! -f "$file" ] || [ -L "$file" ]; then
    continue
  fi
  if [ -n "${license_files[$file]:-}" ]; then
    continue
  fi
  files+=("$file")
done < <(git ls-files -z --cached --others --exclude-standard)

[ "${#files[@]}" -gt 0 ] || fail "no files to process in $root"

args=(-c "$holder" -l "$license" -s=only -v)
if [ -n "$year" ]; then
  args+=(-y "$year")
fi
if [ "$check" -eq 1 ]; then
  args+=(-check)
fi

echo "license-sign: $license, $holder, ${#files[@]} candidate files" >&2
printf '%s\0' "${files[@]}" | xargs -0 addlicense "${args[@]}" -- || exit 1
