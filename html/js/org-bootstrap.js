$( document ).ready(function() {
    $.urlParam = function(name){
        var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results==null) {
            return null;
        }
        return decodeURI(results[1]) || 0;
    }

    if ($.urlParam('print') != null) {
        $(".slide").removeClass('w-100');
        var inner = $(".carousel-inner");
        inner.siblings().remove();
        inner.unwrap().unwrap().unwrap();
        inner.removeClass('carousel-inner');
        // inner.children().removeClass('carousel-item').addClass('slide');
        inner.children().children().unwrap();
        $(".slide").removeClass('d-block').removeClass('slide').addClass('slide-print');
        // window.print();
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

        $('<a href="?print=true">[Drucken]</a>').appendTo('#table-of-contents');

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

        $("pre.src").each(function (idx, block) {
            var button = $('<button class="execute">Load Interpreter</button>');
            button.insertBefore(block);
            button.click(function(e) {
                // Click Klipse
                if ($("script#script-klipse").length == 0) {
                    var script = document.createElement('script');
                    script.id = 'script-klipse';
                    script.type='text/javascript';
                    script.src = "https://storage.googleapis.com/app.klipse.tech/plugin_prod/js/klipse_plugin.min.js";
                    script.onload = function() {
                        $("button.execute").detach();
                    }
                    document.head.appendChild(script);
                    var css = document.createElement('link');
                    css.rel = 'stylesheet'
                    css.type = 'text/css';
                    css.href = 'https://storage.googleapis.com/app.klipse.tech/css/codemirror.css';
                    script.id = 'script-klipse';
                    document.head.appendChild(css);
                }
            });
        });

        window.klipse_settings = {
            selector_eval_html: '.src-html',
            selector_eval_js: '.src-js',
            selector_eval_python_client: '.src-python',
            selector_eval_scheme: '.src-scheme',
            selector: '.src-clojure',
            selector_eval_ruby: '.src-ruby',
            eval_idle_msec: 100
        };
    }
});
