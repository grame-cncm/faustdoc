// Keys typed in a program are not the site's shortcuts.
//
// The mkdocs theme (its js/base.js) binds n, p, s and ? on the document to
// the next page, the previous page, the search and the help. It leaves out a
// key typed in an <input> or a <textarea> by testing the event's target. The
// editors of faust-web-component are in a shadow DOM: a key typed there
// reaches the document with the <faust-editor> or <faust-widget> element as
// its target, so "s" typed in a program opened the search instead of being
// typed, and "?" opened the help.
//
// This listener, on <html>, runs after the editor (inside the shadow DOM) has
// handled the key and before the theme's listener (on the document), whatever
// order the scripts load in. It stops a key whose real target, the first
// element of its composed path, is editable.
(function () {
    "use strict";

    function editable(node) {
        return node instanceof Element &&
            (node.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(node.tagName));
    }

    document.documentElement.addEventListener("keydown", function (e) {
        var path = e.composedPath ? e.composedPath() : [];
        if (path.length && editable(path[0])) e.stopPropagation();
    });
})();
