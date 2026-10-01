/* Copyright (C) 2023 Cadence Design Systems, Inc. All rights reserved. */

/* ================================================================
 * Hierarchy path management
 * ================================================================ */

function getLocalLCV() {
    const lcvElem = document.querySelector('#header .libCellView');
    return ['.libName', '.cellName', '.viewName'].map(
        (c) => lcvElem.querySelector(c).innerText
    );
}

function getQueryHierPath() {
    let params = new URLSearchParams(document.location.search);
    let hierPathStr = params.get('hierPath');
    if (hierPathStr) {
        return expandHierPath(parseHierPath(hierPathStr));
    }
    return [];
}

/* The query form of the hier path looks like a sequence of
 * comma-separated substrings, each of which contains solidus-delimited 
 * identifiers (oaScalarNames).  This takes advantage of the fact that an
 * oaScalarName can't contain comma or solidus.  For example:
 * 
 *     a/b/c,d,e/f
 *
 */
function parseHierPath(str) {
    return str.split(',').map((item) => item.split('/'));
}

function formatHierPath(hierPath) {
    return hierPath.map((item) => item.join('/')).join(',');
}

/* To save space in the URI, avoid repeating consecutive names in paths.  If all
 * items in the the path are "schematic", it shouldn't be repeated.  For
 * example:
 * 
 *     [["lib", "upper", "schematic", "I1"],
 *      ["lib", "lower", "schematic", "I99"]]
 * 
 * becomes:
 * 
 *     [["", "upper", "", "I1"], ["lib", "lower", "schematic", "I99"]]
 */
function expandHierPathTransformer(oldItem, reference) {
    const newItem = oldItem.map(
        (value, index) => (value.length == 0) ? reference[index] : value
    );
    // Output is fully expanded & should be used as the reference for the next op
    return [newItem, newItem];
}

function compressHierPathTransformer(oldItem, reference) {
    const newItem = oldItem.map(
        (value, index) => (value == reference[index] ? '' : value)
    );
    // Input is fully expanded & should be used as the refernce for the next op
    return [newItem, oldItem];
}

function transformHierPath(hierPath, transformer, relativeTo) {
    let result = new Array(hierPath.length);

    hierPath.reduceRight((ref, item, index) => {
        const [transformed, nextRef] = transformer(item, ref);
        result[index] = transformed;
        return nextRef;
    }, relativeTo);

    return result;
}

function expandHierPath(compressed, relativeTo = [...getLocalLCV(), '']) {
    return transformHierPath(compressed, expandHierPathTransformer,
                             relativeTo);
}

function compressHierPath(expanded, relativeTo = ['','','','']) {
    return transformHierPath(expanded, compressHierPathTransformer,
                             relativeTo);
}

function makeAscendURL(hierPath, libName, cellName, viewName, instName) {
    const href = `../../../${libName}/${cellName}/${viewName}/index.html`;
    const destination = new URL(href, location);

    if (hierPath.length > 0) {
        const hierPathStr =
            formatHierPath(compressHierPath(hierPath,
                [libName, cellName, viewName, '']));
        destination.search = new URLSearchParams({ hierPath: hierPathStr });
    }

    return destination;
}

function urlToHierItem(url) {
    let match = /([^\/]*)\/([^\/]*)\/([^\/]*)\/index.html/.exec(url.pathname);
    if (match) {
        return [match[1], match[2], match[3], ''];
    }
    return ['','','',''];
}

function descend(href, instName) {
    let hierPath = getQueryHierPath();
    let selfItem = getLocalLCV();

    selfItem.push(instName);
    hierPath.push(selfItem);

    
    const destination = new URL(href, location);
    const hierPathStr = 
        formatHierPath(compressHierPath(hierPath, urlToHierItem(destination)));
    destination.search = new URLSearchParams({ hierPath: hierPathStr });

    location.href = destination;
}

function ascend() {
    const hierPath = getQueryHierPath();
    if (hierPath.length == 0) {
        location.href = '../../../index.html';
        return;
    }

    const destItem = hierPath.pop();
    location.href = makeAscendURL(hierPath, ...destItem);
}

/* ================================================================
 * Handling of navigation & properties area
 * ================================================================ */

function instBaseId(hashId = location.hash, prefix = '') {
    const match = /^#?inst[^_]*_(.*)/.exec(hashId);
    return match ? prefix + match[1] : null;
}

function instNavId(hashId) {
    return instBaseId(hashId, 'instNav_');
}

function instPropsId(hashId) {
    return instBaseId(hashId, 'instProps_');
}

function showProps(hashId) {
    const hint = document.getElementById('propertiesHint');
    const requested = document.getElementById(instPropsId(hashId)) || hint;
    if (!requested) return;

    function sync(e) {
        e.style.display = (e === requested) ? 'block' : 'none';
    }

    sync(hint);
    document.querySelectorAll('#properties .instProps').forEach(sync);
}

function descendFromId(hashId) {
    const navRow = document.getElementById(instNavId(hashId));
    if (!navRow) { return; }

    const instName = navRow.querySelector('.instName');
    const switchLink = navRow.querySelector('a.cellName');

    if (instName && switchLink) {
        descend(switchLink.href, instName.innerText);
    }
}

/* ================================================================
 * Canvas viewbox manipulation
 * ================================================================ */

/* SVG scale factor.  This is fixed by schExportSVG(). */
const CANVAS_DBU_PER_UU = 160;

/* Regexp that matches the SVG viewBox attribute: 4 numbers separated by
 * whitespace and/or commas */
const VIEW_BOX_REGEXP = function () {
    const num_re = '([+-]?\\d*\\.?\\d+)';
    const sep_re = '\\s*[\\s,]\\s*';
    const attr_re = num_re + sep_re + num_re + sep_re + num_re + sep_re + num_re;
    return new RegExp(attr_re);
}();

/* Get the view box of an SVG DOM element, as a DOMRect. */
function getViewBoxRect(elem) {
    const attr = elem.getAttribute('viewBox');
    if (attr) {
        const match = VIEW_BOX_REGEXP.exec(attr);
        if (match) {
            return new DOMRect(
                parseFloat(match[1]),
                parseFloat(match[2]),
                parseFloat(match[3]),
                parseFloat(match[4]));
        }
    }
    return new DOMRect();
}

/* Set the view box of an SVG DOM element from a DOMRect. */
function setViewBoxRect(elem, rect) {
    /* Ensure that the original view box is not lost */
    if (!elem.getAttribute('js_initialViewBox')) {
        elem.setAttribute('js_initialViewBox', elem.getAttribute('viewBox'));
    }

    elem.setAttribute('viewBox',
        `${rect.left} ${rect.top} ${rect.width} ${rect.height}`);
}

function resetViewBoxRect(svg) {
    const initRect = svg.getAttribute('js_initialViewBox');
    if (initRect) {
        svg.setAttribute('viewBox', initRect);
    }
}

/* Zoom in on an SVG element by some factor, keeping the specified point in
 * client space stable w.r.t. the SVG content */
function zoomSVG(svg, clientPoint, factor) {
    const clientRect = svg.getBoundingClientRect();
    const viewRect = getViewBoxRect(svg);

    const relX = (clientPoint.x - clientRect.left) / clientRect.width;
    const relY = (clientPoint.y - clientRect.top) / clientRect.height;

    /* Limit the maximum zoom in.  This prevents weird numerical issues and SVG
     * rendering issues at high zoom levels */

    const limitedFactor =
        Math.max(factor,
            CANVAS_DBU_PER_UU / Math.min(viewRect.height, viewRect.width));

    const deltaWidth = (limitedFactor - 1) * viewRect.width;
    const deltaHeight = (limitedFactor - 1) * viewRect.height;

    const deltaLeft = -relX * deltaWidth;
    const deltaTop = -relY * deltaHeight;

    setViewBoxRect(svg, new DOMRect(viewRect.left + deltaLeft,
        viewRect.top + deltaTop,
        viewRect.width + deltaWidth,
        viewRect.height + deltaHeight));
}

/* Zoom the SVG around a client point.  If the zoomDirection is
 * positive, zoom in by one step; otherwise, zoom out by one step. */
function zoomSVGStep(svg, clientPoint, zoomDirection) {
    const factor = (zoomDirection > 0) ? 1.25 : 0.8;
    zoomSVG(svg, clientPoint, factor);
}

/* Zoom the SVG in or out at its center by one step. */
function zoomSVGStepCenter(svg, zoomDirection) {
    const rect = svg.getBoundingClientRect();
    zoomSVGStep(svg,
        new DOMPoint((rect.left + rect.right) / 2,
            (rect.top + rect.bottom) / 2),
        zoomDirection);
}

/* Zoom an SVG element in on some client rectangle, such that the new view fits 
 * the whole of the original view area enclosed by the client rectangle. */
function zoomSVGRect(svg, zoomRect) {
    const clientRect = svg.getBoundingClientRect();

    const center = new DOMPoint((clientRect.left + clientRect.right) / 2,
        (clientRect.top + clientRect.bottom) / 2);

    /* Pan so that the centre of the zoom rect is centred in the client area */
    const deltaLeft = ((zoomRect.left + zoomRect.right) / 2 - center.x);
    const deltaTop = ((zoomRect.top + zoomRect.bottom) / 2 - center.y);

    panSVG(svg, new DOMPoint(deltaLeft, deltaTop));

    /* Zoom to fit the zoom rect into the client area */
    const factor = Math.max(zoomRect.width / clientRect.width,
        zoomRect.height / clientRect.height);
    zoomSVG(svg, center, factor);
}


function panSVG(svg, clientVelocity) {
    const clientRect = svg.getBoundingClientRect();
    const viewRect = getViewBoxRect(svg);

    const deltaLeft = clientVelocity.x * viewRect.width / clientRect.width;
    const deltaTop = clientVelocity.y * viewRect.height / clientRect.height;

    setViewBoxRect(svg, new DOMRect(viewRect.left + deltaLeft,
        viewRect.top + deltaTop,
        viewRect.width,
        viewRect.height));
}

function panSVGRelative(svg, relVelocity) {
    const viewRect = getViewBoxRect(svg);
    /* Ensure that panning is the same speed in both vertical & horizontal
     * directions */
    const distance = Math.min(viewRect.width, viewRect.height);
    const deltaLeft = relVelocity.x * distance;
    const deltaTop = relVelocity.y * distance;

    setViewBoxRect(svg, new DOMRect(viewRect.left + deltaLeft,
        viewRect.top + deltaTop,
        viewRect.width,
        viewRect.height));
}

/* ================================================================
 * Canvas events
 * ================================================================ */

function getCanvasSVG() {
    return document.querySelector('#canvas svg');
}

/* Create a callback that encloses the previous position in the pan
 * operation.  This allows each pan operation to track its incremental offset
 * without using any global state other than handler registrations. */
function makeCanvasPanHandler(canvasSVG, startClientX, startClientY) {
    return (ev) => {
        panSVG(canvasSVG, {
            x: startClientX - ev.clientX,
            y: startClientY - ev.clientY
        });
        startClientX = ev.clientX;
        startClientY = ev.clientY;
    }
}

function makeCanvasZoomHandler(zoomElem, startPageX, startPageY) {
    return (ev) => {
        zoomElem.style.left = String(Math.min(startPageX, ev.pageX));
        zoomElem.style.top = String(Math.min(startPageY, ev.pageY));
        zoomElem.style.width = String(Math.abs(ev.pageX - startPageX));
        zoomElem.style.height = String(Math.abs(ev.pageY - startPageY));
    };
}

function installCanvasInstEvents(rect) {
    let match = /^instMapArea_(.*)/.exec(rect.id);
    if (match) {
        let href = '#inst_' + match[1];

        // Show the properties transiently if the bbox is hovered
        rect.addEventListener('mouseenter', () => showProps(rect.id));
        rect.addEventListener('mouseleave', () => showProps());

        // Show the properties persistently if the bbox is clicked
        rect.addEventListener('click', (ev) => {
            ev.preventDefault();
            location.replace(href);
            // Prevent event from hitting canvas object
            ev.stopPropagation();
        });

        // Descend into instance if the bbox is double-clicked
        rect.addEventListener('dblclick', (ev) => {
            ev.preventDefault();
            descendFromId(rect.id);
        });
    }
}

function installCanvasEvents(canvasSVG) {
    canvasSVG.addEventListener('click', (ev) => {
        switch (ev.button) {
            /* Primary button (usually left button) */
            case 0:
                location.hash = '';
                ev.preventDefault();
                break;
            /* Auxiliary button (usually wheel button or mouse button) */
            case 1:
                /* This button is used for drag panning */
                ev.preventDefault()
                break;
            /* Secondary button (usually right button) */
            case 2:
                /* This button is used for box zoom */
                ev.preventDefault()
                break;
        }
    });

    canvasSVG.addEventListener('wheel', (ev) => {
        ev.preventDefault();
        zoomSVGStep(canvasSVG, new DOMPoint(ev.clientX, ev.clientY), ev.deltaY);
    });

    canvasSVG.addEventListener('mousedown', (evDown) => {

        const dispatchOnce = { once: true };

        switch (evDown.button) {
            /* Auxiliary button (usually wheel button or middle button) */
            case 1:
                const pan = makeCanvasPanHandler(canvasSVG,
                    evDown.clientX,
                    evDown.clientY);
                canvasSVG.classList.add('js-svg-pan');
                window.addEventListener('mousemove', pan);
                window.addEventListener('mouseup', () => {
                    canvasSVG.classList.remove('js-svg-pan');
                    window.removeEventListener('mousemove', pan);
                }, dispatchOnce);
                evDown.preventDefault();
                break;

            /* Secondary button (usually right button) */
            case 2:
                /* Create an box showing the area that will be zoomed into on
                 * mouse up, as a sibling element of the SVG area. */
                let zoomElem = document.getElementById('js-canvas-zoom-indicator');
                if (!zoomElem) {
                    zoomElem = document.createElement('div');
                    zoomElem.id = 'js-canvas-zoom-indicator';
                    canvasSVG.parentElement.append(zoomElem);
                }

                const zoom =
                    makeCanvasZoomHandler(zoomElem, evDown.pageX, evDown.pageY);

                canvasSVG.classList.add('svg-zoom');
                window.addEventListener('mousemove', zoom);
                window.addEventListener('mouseup', (evUp) => {
                    canvasSVG.classList.remove('svg-zoom');
                    window.removeEventListener('mousemove', zoom);
                    zoomElem.remove();

                    const rect = 
                        new DOMRect(Math.min(evUp.clientX, evDown.clientX),
                                    Math.min(evUp.clientY, evDown.clientY),
                                    Math.abs(evUp.clientX - evDown.clientX),
                                    Math.abs(evUp.clientY - evDown.clientY));

                    /* Only zoom if a certain minimum size has been dragged out. */
                    if (rect.height + rect.width >= 2) {
                        zoomSVGRect(canvasSVG, rect);
                    }
                }, dispatchOnce);
                evDown.preventDefault();
                break;
        }
    });

    /* Prevent displaying a context menu from the canvas SVG, because it
     * interferes with dragging the right mouse button to zoom in. */
    canvasSVG.addEventListener('contextmenu', (ev) => ev.preventDefault());
}

installCanvasEvents(getCanvasSVG());
getCanvasSVG().querySelectorAll('rect').forEach(installCanvasInstEvents);

/* ================================================================
 * Descend & ascend handling
 * ================================================================
 * 
 * To make sure that hierarchy information is passed along while descending the
 * hierarchy, it's necessary to make sure that all hyperlinks that might descend
 * the hierarchy do so with the appropriate search string.
 * 
 * There are 2 ways this could be achieved:
 * 
 * - dynamically rewrite all of the HREFs to include the search string
 * - add onclick handlers that intercept link clicks and add the search string
 * 
 * It's slightly cleaner to use the onclick handlers: we don't have to
 * modify the DOM and thereby change the semantic content of the page; and the
 * user gets a more concise preview of the destination of the link while
 * hovering over it with the mouse cursor.
 */

function installDescendEvents() {

    function installEvents(element, hashId) {
        element.onclick = (ev) => {
            ev.preventDefault();
            descendFromId(hashId);
        };
    }

    document.querySelectorAll('#navigation tr').forEach((row) => {
        row.querySelectorAll('a.cellName').forEach(
            (link) => installEvents(link, row.id));
    });

    document.querySelectorAll('#properties .instProps').forEach((props) => {
        props.querySelectorAll('.instPreview a').forEach(
            (link) => installEvents(link, props.id));
    });
}

/* Add hierarchy navigation breadcrumbs into the top of the page. */

function makeIndexBreadcrumb() {
    const elem = document.createElement('a');
    elem.classList.add('js-breadcrumb');
    elem.id = 'js-index-breadcrumb';
    elem.href = '../../../index.html';
    elem.append('Index');
    return elem;
}

/** @todo It might be an improvement to make the hierarchy links include a
 * fragment that pre-selects the item to which the link ascends.  To do this
 * may require a Javascript implementation of _schEncodeXMLLocalName(). */

function makeHierBreadcrumb(hierPath, libName, cellName, viewName, instName) {
    const elem = document.createElement('a');
    elem.classList.add('js-breadcrumb')
    elem.classList.add('js-hier-breadcrumb');
    elem.href = makeAscendURL(hierPath, libName, cellName, viewName, instName);
    elem.title = title = `${libName} - ${cellName} - ${viewName}`;
    elem.append(instName);
    return elem;
}

function makeTailBreadcrumb(instName) {
    const elem = document.createElement('span');
    elem.classList.add('js-breadcrumb');
    elem.id = 'js-tail-breadcrumb';
    elem.append(instName);
    return elem;
}

function injectBreadcrumbs() {
    const block = document.createElement('div');
    block.id = 'js-breadcrumbs-block';
    block.append('Hierarchy: ');
    block.append(makeIndexBreadcrumb());
    block.append(' \u{2192} ');

    const tailName = 
        getQueryHierPath().reduce((ascendName, item, index, hierPath) => {
            const [libName, cellName, viewName, instName] = item;
            block.append(makeHierBreadcrumb(hierPath.slice(0, index),
                                            libName, cellName, viewName,
                                            ascendName));
            block.append(' / ');
            return instName;
        }, 'Top');

    block.append(makeTailBreadcrumb(tailName));

    document.body.append(block);
}

installDescendEvents();
injectBreadcrumbs();

/* ================================================================
 * Window events
 * ================================================================ */

window.addEventListener('hashchange', () => showProps());

/* ================================================================
 * Keybindings
 * ================================================================ */

document.addEventListener('keydown', function (ev) {
    let zoom = function (direction) {
        zoomSVGStepCenter(getCanvasSVG(), direction)
    };
    let pan = function (x, y) {
        panSVGRelative(getCanvasSVG(), { x: x * 0.2, y: y * 0.2 });
    };

    switch (ev.key) {
        case 'f':
        case 'F':
            resetViewBoxRect(getCanvasSVG());
            break;
        case 'e':
        case 'E':
            if (ev.ctrlKey) {
                ascend();
            } else {
                descendFromId();
            }
            break;
        case '[': zoom(1); break;
        case ']': zoom(-1); break;
        case 'Up':
        case 'ArrowUp': pan(0, -1); break;
        case 'Down':
        case 'ArrowDown': pan(0, 1); break;
        case 'Left':
        case 'ArrowLeft': pan(-1, 0); break;
        case 'Right':
        case 'ArrowRight': pan(1, 0); break;
    }
});

/* ================================================================
 * Initialize global state
 * ================================================================ */

/* Fix up style of SVG container div element to match SVG background color.  Do
 * this at runtime to allow static CSS + JS files to be used with generated SVG
 * data that may be produced with different color modes. */
document.getElementById('canvas').style.backgroundColor =
    document.querySelector('#canvas svg').style.backgroundColor;

showProps();
