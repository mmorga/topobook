# TODO

* Make a cover image by using Imagemagick montage to put together the color JPEGs image tiles extracted from the SVG.
* Extract map information items from SVG and create a page for that.
* Make a simplified version of the overall map with page indicators for the detail pages
* Scale the full page appropriately for kindle resolution
* Look into reducing resolution that is tough to see (may not be possible)
* Break up each detail page from the overall file
    - Allow for overlap
    - Eliminate the map edges
    - Would it be possible to determine the lat-long bounds of each page?
    - Figure out the right page size/resolution for best viewing
    - Make each page SVG smaller by deleting items outside the viewbox boundary (possibly with Chrome)

# Book building Notes

Aside: What fonts are needed in the SVG?

# Files to generate:

* content.opf
* toc.ncx
* Disclaimer page
* Map info page
* Map overview HTML
* Map detail HTML page(s)
* Images
    - JPEG Cover from PDF JPEGs (& cover.html)
    - Back Cover?
    - SVG Overview
    - SVG Detail pages

# Files to create:

* style.css

