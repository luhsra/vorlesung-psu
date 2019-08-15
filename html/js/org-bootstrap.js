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
        toc.insertAfter(".title");

        $('#content, #postamble').wrapAll("<div class='container'><div id='main-row' class='row'><div class='col-md-9'></div></div></div>");

        $('#table-of-contents').wrapAll("<div class='card bg-light mb-2 pb-1'></div>");
        $('#table-of-contents').addClass("well");
        var url = window.location.href.match(/.*\//) + "index.html";
        $('<a href="'+url+'">[Index]</a>').appendTo('#table-of-contents');

        var url = window.location.href.replace('.html', '-slides.pdf');
        $('<a href="'+url+'">[Slides]</a>').appendTo('#table-of-contents');

        $('<a href="?print">[Drucken]</a>').appendTo('#table-of-contents');

        $('#footnotes').appendTo('.col-md-9');

        $("img.slide").each(function (idx, img) {
            $(img).click(function(e) {
                if(e.shiftKey || e.ctrlKey || e.altKey) {
                    $(img).closest('.carousel').carousel('prev');
                } else {
                    $(img).closest('.carousel').carousel('next');
                }
                return true;
            });
        });
    }
});
