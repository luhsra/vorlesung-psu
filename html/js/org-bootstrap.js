class StudipForum {
    
    constructor() {
        this.api_url =    "https://gbs.sra.uni-hannover.de";
        this.studip_url = "https://studip.uni-hannover.de";
        this.cid = "a34a39c64894b4699072b396f6e4d6a5"; // Vorlesung: SS2020
    }

    categories(cb) {
        var url = `${this.api_url}/info/forum/${this.cid}/categories/`;
        $.ajax({url: url, dataType: "json", data: {"limit": 10000},
                success: function(data) {
                    var categories = data.entries.collection;
                    var ret = {};
                    for (let cat in categories) {
                        var name = categories[cat].entry_name;
                        var category_id = categories[cat].category_id;
                        ret[name] = category_id;
                    }
                    cb(ret)
                }});
    }

    topics(category_id, cb) {
        var url = `${this.api_url}/info/forum/${this.cid}/areas/${category_id}/`;
        $.ajax({url: url, dataType: "json", data: {"limit": 10000},
                success: function(data) {
                    var topics = data.entries.collection;
                    var ret = {};
                    for (let cat in topics) {
                        var name = topics[cat].subject;
                        var topic_id = topics[cat].topic_id;
                        ret[name] = topic_id;
                    }
                    cb(ret)
                }});
    }

    entries(topic_id, cb) {
        var url = `${this.api_url}/info/forum/${this.cid}/entries/${topic_id}`;
        $.ajax({url: url, dataType: "json", data: {"limit": 10000},
                success: function(data) {
                    cb(data.entries.children);
                }});
    }

    link(topic_or_entry_id) {
        return `https://studip.uni-hannover.de/plugins.php/coreforum/index/index/${topic_or_entry_id}/?cid=${this.cid}#${topic_or_entry_id}`;
    }
}

function insert_entries(forum, entries) {
    var html = "<ul class='studip-forum-entries'>";
    for (let idx in entries) {
        var entry = entries[idx];
        var id = entry.topic_id;
        console.log(entry);

        var subject = $(entry.subject).text();
        var mkdate = new Date(parseInt(entry.mkdate)*1000);
        var chdate = new Date(parseInt(entry.chdate)*1000);
        var delta = new Date(new Date() - chdate);
        var deltaHours = delta.getUTCHours()
        var humandate= Math.floor(deltaHours/24)+"d"+(deltaHours%24)+"h"+delta.getUTCMinutes()+"m";

        var listItem = `<li>[<span class='date'>${mkdate.toLocaleDateString()}</span>, updated:<span class='delta'>${humandate}</span>] <a href="${forum.link(id)}">${subject}</a></li>`;
        html += listItem;

        var m = new RegExp('\\[([0-9]{2}-[^[]*)\]').exec(subject);
        if (m != null) {
            $(`h2#${m[1]}, h3#${m[1]}`).each(function(idx, headline) {
                console.log(headline);
                var list = headline
                if (!$(headline).next().hasClass('studip-forum-entries')) {
                    list = $("<ul class='studip-forum-entries'></ul>");
                    list.insertAfter(headline);
                }
                list.append(listItem);
            });
        }

    }
    html += "</ul>"
    var list = $($.parseHTML(html)).wrapAll("<ul></ul>");
    list.insertAfter(".forum-title");
}

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

        $('#table-of-contents').wrapAll("<div id='toc-well' class='card bg-light mb-2 pb-1'></div>");
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

            // The Forum
            var forum = new StudipForum();
            var vorlesung = $(".subtitle").text();

            forum.categories(function(categories) {
                forum.topics(categories["Skript"], function(topics) {
                    if (typeof topics[vorlesung] == 'undefined') return;
                    // Sorry, Mum!
                    var url = forum.link(topics[vorlesung]);
                    var headline = $(`<h3 class='forum-title'><span class="section-number-2">0</span> StudIP-Forum: <a href="${url}">PSÜ/Skript/${vorlesung}</a></h3>`);
                    headline.insertAfter('#toc-well');
                    forum.entries(topics[vorlesung], function(entries) {
                        insert_entries(forum, entries);
                    });
                })
            });
        }

        $("h2, h3").each(function(idx, headline) {
            if (headline.id) {
                $('<a class="headlineref"  href="#'+headline.id+'">&#128279;</a>').appendTo(headline);
            }
        });

        $('#footnotes').appendTo('.col-md-9');

        $("div.carousel").each(function (idx, carousel) {
            $(carousel).find("div.carousel-inner").click(function(e) {
                if(e.shiftKey || e.ctrlKey || e.altKey) {
                    $(carousel).carousel('prev');
                } else {
                    $(carousel).carousel('next');
                }
                return true;
            });
        });

        $("pre.src-python, pre.src-javascript").each(function (idx, block) {
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
            selector_eval_js: '.src-javascript',
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
