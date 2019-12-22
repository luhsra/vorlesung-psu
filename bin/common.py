import shlex
import re
import sys

def normalize_topic(topic):
    topic = topic.replace(" ", "_").replace('"', "_").lower()
    topic = re.sub("[^a-zA-Z_]", "_", topic)


    return topic

def parse_topic_line(line):
    line = line.decode('latin-1', errors='replace')
    pages, block, topic = line.strip().split(":", 2)
    topic = normalize_topic(topic)
    start, end = map(int, pages.split("-"))
    return ((start, end), block, topic)


def parse_block_src(line):
    if "#+begin_src" in line.lower():
        tokens = shlex.split(line)
        def with_attr(key):
            if key in tokens:
                return tokens[tokens.index(key)+1]
        ret = {'type': 'begin_src',
               'line': line,
               'language': tokens[1],
               'tangle': with_attr(':tangle') != "no",
               'title': with_attr(':title')}
        return ret

    if "#+end_src" in line.lower():
        return {'type': 'end_src', 'line': line}
