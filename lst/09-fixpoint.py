# coding: utf-8


#s0
# init():      Initialer Zustand für Node
# merge():     Zustands-Merge-Funktion
# transform(): Block-Transformation Funktion
# graph:       Der Graph den wir bearbeiten wollen
def fixpoint(init, merge, transform, graph):
#e0
#s1
    states = {}                    # Verwende die Initialisierungsfunktion init(),
    for node in graph.nodes:       # um einen initialen Zustand für jeden Knoten
        states[node] = init(node)  # zu präparieren.
#e1
#s2
    worklist = list(graph.nodes)   # Worklist-Algorithmus: Laufe solange, bis
    while worklist != []:          # die Worklist leer ist. Zu Beginn, besuchen
        node = worklist.pop()      # wir jeden Knoten.
#e2
#s3
        d_ins = []                            # In jedem Schritt, sammeln wir die
        for pred in graph.predecessors[node]: # Zustände der Vorgängerknoten ein
            d_ins.append(states[pred])        # und kombinieren diese mit der
        d_in = merge(d_ins)                   # Zustands-Merge Funktion merge()
#e3
#s4
        d_out = transform(node, d_in)   # Wende die Transformations-Funktion an
        if d_out == states[node]:       # Ändert sich der Knoten-Zustand nicht,
            continue                    # sind wir für diesen Schritt fertig.
#e4
#s5
        states[node] = d_out                 # Ändert sich der Zustand eines 
        for succ in graph.successors[node]:  # Knotens werden alle Folge-Knoten 
            worklist.append(succ)            # noch einmal besucht.
#e5
    return states


class Graph:
    def __init__(self):
        self.nodes        = [-1, 0, 1, 2, 3]
        self.predecessors = {
            -1: [-1],
            0:  [-1, 3],
            1:  [0],
            2:  [0],
            3:  [1,2],
        }
        self.successors = {
            0: [1,2],
            1: [3],
            2: [3],
            3: [0],
        }
        self.entry = 0

graph = Graph()

import functools
def merge(states):
    return functools.reduce(lambda a, b: a & b, states)

def transform(block, state):
    if block >= 0:
        state |= 1 << block
        return state
    return 0

x = fixpoint(lambda node: 0, merge, transform, graph)
print(x)
