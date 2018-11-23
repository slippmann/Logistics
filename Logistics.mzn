%======================= PROBLEM DATA ========================

int: graph_size;
int: start;
int: n_dests;
array[1..n_dests] of int: dest;
int: n_edges;
array[1..n_edges] of int: from;
array[1..n_edges] of int: to;
array[1..n_edges] of int: cost;


%======================== ASSERTIONS =========================

constraint assert(graph_size > 1,
                  "Graph must contain two or more nodes");
constraint assert(start >= 1 /\ start <= graph_size,
                  "Starting value must be in range 1 to graph_size");
constraint assert(n_edges >= 1,
                  "Graph must contain at least one edge");
constraint assert(n_dests >= 1,
                  "At least one destination must be chosen");

constraint assert(forall(i in 1..n_dests)(dest[i] > 0 /\ dest[i] <= graph_size),
                  "All \"dest\" values should be in range 1 to graph_size");
constraint assert(forall(i in 1..n_edges)(from[i] > 0 /\ from[i] <= graph_size),
                  "All \"from\" values should be in range 1 to graph_size");
constraint assert(forall(i in 1..n_edges)(to[i] > 0 /\ to[i] <= graph_size),
                  "All \"to\" values should be in range 1 to graph_size");


%====================== SET DEFINITIONS ======================

set of int: fullEdgeSet = 1..n_edges;
set of int: destSet = 1..n_dests;
set of int: nodeSet = 1..graph_size;
set of int: edgeSet = 1..graph_size-1;
int: maxNodes = graph_size;


%====================== SOLUTION FORMAT ======================

% Sub-tree variables
array[edgeSet] of var min(cost)..max(cost): edges;
array[nodeSet] of var nodeSet: nodes;

% Helper Variable (to determine which edges are valid)
var nodeSet: nodes_visited;


%===================== PROBLEM CONSTRAINTS ===================

% First node is the start node
constraint nodes[1] == start;

% Every destination is in node set
constraint forall(d in destSet)(
               exists(n in nodeSet)(
                   nodes[n] == dest[d]
               )
           );

% Make sure all future nodes are connected to some previous node
constraint forall(n2 in 2..maxNodes)(
               exists(k in fullEdgeSet, n1 in nodeSet where n1 < n2)(
                   ((from[k] == nodes[n1] /\ to[k]   == nodes[n2]) \/
                    (to[k]   == nodes[n1] /\ from[k] == nodes[n2])) /\
                   cost[k] == edges[n2-1]
               )
           );
           
% Find max nodes to visit
constraint exists(n in nodeSet, d in destSet)(
               nodes[n] == dest[d] /\
               nodes_visited == n /\
               forall(m in nodeSet, b in destSet)(
                   (nodes[m] == dest[b]) -> (m <= n)
               )
           );

% Calculate the total cost from start to destination(s)
var int: totalCost = sum(e in 1..nodes_visited-1)(edges[e]);
solve minimize totalCost;


%===================== OUTPUT ========================

output ["min_cost(\(totalCost))"];