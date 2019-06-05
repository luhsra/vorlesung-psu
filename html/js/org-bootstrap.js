$( document ).ready(function() {
    if (window.location.search.search('print') != -1) {
        $(".slide").removeClass('w-100').addClass('d-print-block');
        var inner = $(".carousel-inner");
        inner.siblings().remove();
        inner.unwrap().unwrap().unwrap();
        inner.removeClass('carousel-inner').addClass('row');
        inner.children().removeClass('carousel-item').addClass('col-md-6');
        inner.children().children().addClass('w-100');
        window.print();
    } else {
        // The content (and postamble) should be in a container.
        var toc = $('#table-of-contents').detach();

        $('#content, #postamble').wrapAll("<div class='container'><div id='main-row' class='row'><div class='col-md-9'></div></div></div>");
        toc.appendTo('#main-row');
        $('#table-of-contents').addClass('nav-list');
        $('#table-of-contents').wrapAll("<div class='col-md-3' style='margin-top: 100px;'></div>");
        var url = window.location.href.match(/.*\//) + "index.html";
        $('<a href="'+url+'">[Index]</a>').appendTo('#table-of-contents');

        var url = window.location.href.replace('.html', '-slides.pdf');
        $('<a href="'+url+'">[Slides]</a>').appendTo('#table-of-contents');

        $('<a href="?print">[Drucken]</a>').appendTo('#table-of-contents');

        $('#footnotes').appendTo('.col-md-9');

    }
});
