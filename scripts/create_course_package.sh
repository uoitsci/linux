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
#   A string containing the subject and code concatenated by an
#   underscore.
####################################################################
package_name() {
  local subject="$(echo $1 | tr '[:upper:]' '[:lower:]')"
  local code="$(echo $2 | tr '[:upper:]' '[:lower:]')"

  echo "${subject}-${code}"
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

  # License/copyright file should be included or lintian gets upset.
  
  # This is a makefile and thus must have tabs instead of spaces.
  echo "#!/usr/bin/make -f" > "$1/debian/rules"
  echo "%:" >> "$1/debian/rules"
  echo "\tdh $@" >> "$1/debian/rules"
#  cat <<-EOF > "$1/debian/rules"
##!/usr/bin/make -f
#%:
#	dh $@
#EOF

  cat <<-EOF > "$1/debian/control"
Source: $1
Maintainer: Science Software <software@science.uoit.ca>
Section: misc
Priority: optional
Standards-Version: 3.9.5
Build-Depends: debhelper (>= 9)

Package: $1
Architecture: any
Depends: $2
Description: Course package for $1
 Course package for $1
EOF

  cat <<-EOF > "$1/debian/changelog"
$1 (1.0-1) UNRELEASED; urgency=medium

  * Initial release.

 -- Science Software <software@science.uoit.ca>  $(date -u "+%a, %d %b %Y %H:%M:%S") +0000

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
