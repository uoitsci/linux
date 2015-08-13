#!/usr/bin/env bash

export DEBUILD="/usr/bin/debuild"
export DFLAGS="-us -uc"

####################################################################
# Displays a brief summary and usage information to the user
####################################################################
# Arguments:
#   None
# Returns:
#   None
####################################################################
show_help() {
  cat <<-EOF
build.sh [-h|-?] [-c] -- Builds all packages

Where:
    -h|-? Displays this message
    -c    Cleans all packages of intermediate build files
EOF
}

####################################################################
# Removes all files created by debuild
####################################################################
# Arguments:
#   None
# Returns:
#   None
####################################################################
clean() {
  rm -f $(pwd)/*/debian/*.debhelper.log
  rm -f $(pwd)/*/debian/*.substvars
  rm -f $(pwd)/*/debian/files
  rm -f $(pwd)/*.build
  rm -f $(pwd)/*.changes
  rm -f $(pwd)/*.deb
  rm -f $(pwd)/*.dsc
  rm -f $(pwd)/*.tar.gz
}

####################################################################
# Builds all packages
####################################################################
# Arguments:
#   None
# Returns:
#   None
####################################################################
build() {
  # debuild complains about .DS_Store files, so we must ensure they
  # are removed before building.
  find . -name .DS_Store -delete
  
  for pkg in $(ls */debian/control | cut -d'/' -f1); do
    cd $pkg && debuild -us -uc && cd ..
  done
}

main() {
  while getopts "h?c" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      c)
        echo "Cleaning..."
        clean
        exit 0
        ;;
    esac
  done

  # If we've made it this far, build the packages.
  build
}

main "$@"
