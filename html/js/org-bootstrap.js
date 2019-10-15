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

        var content = $('#content, #postamble');
        content.wrapAll("<div class='container'><div id='main-row' class='row'><div class='col-md-9'></div></div></div>");
        content.children().unwrap();

        $('#table-of-contents').wrapAll("<div class='card bg-light mb-2 pb-1'></div>");
        $('#table-of-contents').addClass("well");

        if (window.location.href.match(/.*handout.html/)) {
            $('<strong> - Druckversion</strong>').appendTo('.subtitle');
        } else {
            var url = window.location.href.match(/.*\//) + "index.html";
            $('<a href="'+url+'">[Index]</a>').appendTo('#table-of-contents');
            var url = window.location.href.replace('.html', '.slides.pdf');
            $('<span>[PDF: </span>').appendTo('#table-of-contents');
            $('<a href="'+url+'">Folien,</a>').appendTo('#table-of-contents');
            var url = window.location.href.replace('.html', '.handout.pdf');
            $('<a href="'+url+'"> Handout</a>').appendTo('#table-of-contents');
            $('<span>]</span>').appendTo('#table-of-contents');
            var url = window.location.href.replace('.html', '.html?print=true');
            $('<a href="'+url+'">[Druckversion]</a>').appendTo('#table-of-contents');
        }

        $("h2, h3").each(function(idx, headline) {
            if (headline.id) {
                $(headline).wrapAll('<a href="#'+headline.id+'"></a>');
            }
        });

        $('#footnotes').appendTo('.col-md-9');

        $("div.carousel").each(function (idx, carousel) {
            $(carousel).click(function(e) {
                if(e.shiftKey || e.ctrlKey || e.altKey) {
                    $(carousel).carousel('prev');
                } else {
                    $(carousel).carousel('next');
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

        requestAnimationFrame(function() {
            if (location.hash) {
                $(document).scrollTop( $(location.hash).offset().top );
            }
        });
    }
});
