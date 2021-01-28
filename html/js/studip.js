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
        //console.log(entry);

        var subject = $(entry.subject).text();
        var mkdate = new Date(parseInt(entry.mkdate)*1000);
        var chdate = new Date(parseInt(entry.chdate)*1000);
        var delta = new Date() - chdate;
        var deltaHours = Math.floor(delta / 1000 / (60 * 60));
        var humandate= Math.floor(deltaHours/24)+"d"+(deltaHours%24)+"h";

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
    if ($.urlParam('print') == null) {
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
});
