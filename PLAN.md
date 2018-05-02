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

# SVG Notes

The converted SVGs (from PDF) contains the following tags:

* clipPath **might be supported**
* defs
* feColorMatrix
* filter
* g **unsupported**
* mask **unsupported** (seems to affect the display of the forested areas)
* path
* rect
* svg
* symbol **unsupported** (used for glyphs - text and labels in document)
* use

The optimized version uses:

* clipPath [1057] **unsupported**
* defs [1]
* feColorMatrix [1]
* filter [1]
* g [1071] **might be supported**
* mask [155] **unsupported**
* path [3675]
* svg [1]
* symbol [1332] **unsupported**
* use [3583]

which eliminates the `rect` element. Which doesn't really help.

Kindle Supports these tags:

* circle
* defs
* ellipse
* feColorMatrix
* filter
* line
* marker
* metadata
* path
* pattern
* polygon
* polyline
* rect
* style
* svg
* text
* use

As of the 2018 Kindle Publishing Guidelines, the following tags are valid

* circle
* clipPath
* defs
* ellipse
* feGaussianBlur
* filter
* g
* line
* linearGradient
* path
* polygon
* polyline
* radialGradient
* rect
* stop
* svg
* title
* use

# Unique Colors in Map
rgb(188,148,109)
rgb(217,194,171)

* rgb(0%,0%,0%)
* rgb(0%,51.799011%,65.899658%) - TBD not found after previous deletions
* rgb(100%,0%,0%) - red - stuff on the legend
* rgb(100%,100%,100%) - white - TBD not found after previous deletions
* rgb(100%,66.699219%,0%) - orange - gridlines  rgb(255,170,0)
* rgb(100%,97.999573%,69.398499%) - pale yellow - word shadow for county
* rgb(30.198669%,30.198669%,30.198669%) - charcoal - TBD unknown?
* rgb(40.79895%,40.79895%,40.79895%) - charcoal - road color on legend
* rgb(48.999023%,7.798767%,7.798767%) - dark red - TBD
* rgb(59.999084%,90.19928%,19.999695%) - TBD not found after previous deletions
* rgb(60.798645%,60.798645%,60.798645%) - med gray - road color
* rgb(61.199951%,61.199951%,61.199951%) - med gray
* rgb(65.098572%,45.498657%,25.898743%) - gray red
* rgb(69.799805%,23.498535%,23.498535%)
* rgb(70.199585%,52.49939%,34.899902%) - med brown
* rgb(74.499512%,90.99884%,100%)   light blue - rivers/streams/washes
* rgb(77.598572%,31.399536%,31.399536%)
* rgb(79.998779%,79.998779%,79.998779%) - gray
* rgb(81.999207%,81.999207%,81.999207%) - gray
* rgb(94.099426%,88.198853%,52.89917%) - TBD


# Information about PDF::Reader

page.attributes[:LGIDict]

Interesting info about the dictionary

# Fonts referenced in the Mesa de Anguila map:

* "ArialMT"
* "ESRIDefaultMarker"
* "ESRINIMAVMAP1&2PT"
* "ESRIOilGasWater"
* "ESRIShields"
* "Georgia"
    - Normal
    - Bold
    - Italic
* "PLTS6"
* "TimesNewRomanPSMT"
* "TrebuchetMS"
    - Normal
    - Bold
    - Italic
