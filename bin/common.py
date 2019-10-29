import shlex

def normalize_topic(topic):
    return topic.replace("?", "").replace(" ", "_").replace('"', "_").lower()

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
