$( document ).ready(function() {
    // The content (and postamble) should be in a container.
    $('#content, #postamble').wrapAll("<div class='container'></div>");
    $('#table-of-contents, .outline-2').wrapAll("<div class='row'></div>");
    $('#table-of-contents').wrap("<div class='col-md-3'></div>");
    $('.outline-2').wrapAll("<div class='col-md-9'></div>");
    $('.col-md-3').before( $('.col-md-9') );
    $('#table-of-contents').addClass('nav-list');
    $('#footnotes').appendTo('.col-md-9');
});
