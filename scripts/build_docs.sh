#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as an error, and ensure errors in pipelines are not masked.
set -euo pipefail

# Build HTML documentation for the project.
# Assumes the docbuild workspace has already been set up by setup_docbuild.sh.
# The output will be located in $HOMEPAGE/docs.

cd docbuild

# Force doc-gen4's `fromDb` step (which emits the HTML) to run every build.
#
# The `:docs` facet in doc-gen4 uses marker files in `.lake/build/doc-data/`
# named `*.docs_built` to track up-to-date-ness. Lake's `buildFileUnlessUpToDate'`
# only checks the marker file and its `.trace` sidecar; it does NOT verify that
# the HTML files `fromDb` would emit are actually present on disk. If the cache
# restored a marker from a previous build but the project's own HTML directory
# was not part of the cache (dependency HTML dirs are cached, but the project's
# own is not), Lake would skip `fromDb` and leave the project's doc pages
# missing, producing 404s after deploy.
#
# Deleting the markers here forces `fromDb` to run every build. It regenerates
# all HTML from the cached database, which is relatively cheap compared to
# rebuilding oleans.
rm -f .lake/build/doc-data/*.docs_built

# Build the docs
~/.elan/bin/lake build $DOCS_FACETS

# Copy documentation to `$HOMEPAGE/docs`
cd ../
mkdir -p $HOMEPAGE
sudo chown -R runner $HOMEPAGE
cp -r docbuild/.lake/build/doc $HOMEPAGE/docs
