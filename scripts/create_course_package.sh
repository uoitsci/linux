#!/usr/bin/env bash
#
# Creates a new package for a particular course given the subject
# and course code.
#
# Author:  Richard Drake <richard.drake@uoit.ca>
#

####################################################################
# Names the package
####################################################################
# Arguments:
#   Subject
#   Course Code
# Returns:
#   The concatenation of subject and course code.
####################################################################
package_name() {
  local subject="$(echo $1 | tr '[:upper:]' '[:lower:]')"
  local code="$(echo $2 | tr '[:upper:]' '[:lower:]')"
  
  echo "${subject}${code}"
}

####################################################################
# Determines the name of the parent package
####################################################################
# Arguments:
#   Faculty
#   Subject
# Returns:
#   The concatenation of uoit-<faculty>-<subject>.
####################################################################
parent_package_name() {
  local subject="$(echo $2 | tr '[:upper:]' '[:lower:]')"

  echo "uoit-$1-${subject}"
}

####################################################################
# Creates a barebones course package
####################################################################
# Arguments:
#   Package Name
#   Parent Package Name
# Returns:
#   0 on success, non-zero otherwise
####################################################################
create_course_package() {
  # If the package already exists, assume we want to keep it; a user
  # may have customized the dependencies.
  if [ -d $1 ]; then
    echo "Package already exists, aborting."
    return
  else
    echo "Creating package $2 -> $1."
  fi

  mkdir -p "$1/debian/source"
  
  # We use the "native" dpkg format.
  echo "3.0 (native)" > $1/debian/source/format

  echo "9" > $1/debian/compat

  # This is a makefile and thus must have tabs instead of spaces.
  echo '#!/usr/bin/make -f' > "$1/debian/rules"
  echo '%:' >> "$1/debian/rules"
  echo -e '\tdh $@' >> "$1/debian/rules"

  # The rules file should be executable or debuild complains.
  chmod +x "$1/debian/rules"

  cat <<-EOF > "$1/debian/control"
Source: $1
Maintainer: Science Software <software@science.uoit.ca>
Section: misc
Priority: optional
Standards-Version: 3.9.5
Build-Depends: debhelper (>= 9)

Package: $1
Architecture: any
Depends: $2,
 \${misc:Depends}
Description: Course package for $1
 Course metapackage for $1 (part of $2).
EOF

  # The changelog format is very specific.  Spaces matter.
  cat <<-EOF > "$1/debian/changelog"
$1 (1.0) UNRELEASED; urgency=medium

  * Initial release.

 -- Science Software <software@science.uoit.ca>  $(date -u "+%a, %d %b %Y %H:%M:%S") +0000

EOF
  # License/copyright file should be included or lintian gets upset.
  cat <<-EOF > "$1/debian/copyright"
Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Source: https://github.com/uoitsci/linux

Files: *
Copyright: 2015, Richard Drake <richard.drake@uoit.ca>
License: ISC
  Copyright (c) 2015 Richard Drake
  .
  Permission to use, copy, modify, and/or distribute this software
  for any purpose with or without fee is hereby granted, provided
  that the above copyright notice and this permission notice appear
  in all copies.
  .
  THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL ISC BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
  DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
  WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  PERFORMANCE OF THIS SOFTWARE.
EOF
}

main() {
  local faculty_name="$(echo $1 | tr '[:upper:]' '[:lower:]')"
  local pkg_name="$(package_name $2 $3)"
  local parent_pkg_name="$(parent_package_name $faculty_name $2)"

  echo ${pkg_name}
  echo ${parent_pkg_name}

  create_course_package "${pkg_name}" "${parent_pkg_name}"
}

if [ "$#" -ne 3 ]; then
  echo "Usage:  create_course_package.sh <faculty> <subject> <code>"
else
  main "$@"
fi
