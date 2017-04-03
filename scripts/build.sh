#!/usr/bin/env bash

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
build.sh [-h|-?] [-c] <package> -- Builds packages

Where:
    -h|-?     Displays this message
    -c        Cleans all packages of intermediate build files
    <package> The name of the package to build.  If this option is
              omitted, all packages are built.
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
  rm -f $(pwd)/*.tar.xz
}

####################################################################
# Builds a specific package
####################################################################
# Arguments:
#   Name of package to build
# Returns:
#   None
####################################################################
build_package() {
  echo "Building $1..."
  pkg="$1"
  
  if [ -d "${pkg}" ]; then
    # Handle Anaconda differently.
    if [ "${pkg}" == "anaconda" ]; then
      # Copy the anaconda installation files to the build directory.
      # The files are hard links, so not specifying -H will
      # essentially double the file size.
      #
      # TODO:  Find a way to make this work without hardcoding the
      #        version number.

      # Build a binary-only package.
      cd "${pkg}" && \
        rsync -ap -H /opt/anaconda anaconda-4.1.0/ && \
        /usr/bin/debuild -b -k0xEF4C1D02 && \
        cd ..
    elif [ "${pkg}" == "maple" ]; then
      # Do nothing.
      echo "Skipping Maple"
    elif [ "${pkg}" == "matlab-full" ]; then
      # Do nothing.
      echo "Skipping MATLAB"
    else
      cd "${pkg}" && /usr/bin/debuild -k0xEF4C1D02 && cd ..
    fi
  fi
}

####################################################################
# Builds all packages
####################################################################
# Arguments:
#   None
# Returns:
#   None
####################################################################
build_all() {
  # debuild complains about .DS_Store files, so we must ensure they
  # are removed before building.
  find . -name .DS_Store -delete

  for pkg in $(ls */debian/control | cut -d'/' -f1); do
    build_package "${pkg}"
  done
}

main() {
  while getopts "h?c" opt; do
    case "${opt}" in
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

  # If we've made it this far, build the package(s).
  if [ $# -eq 0 ]; then
    # Build everything.
    build_all
  else
    # Build the specified package.
    build_package "$1"
  fi
}

main "$@"
