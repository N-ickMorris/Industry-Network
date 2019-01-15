# facilities planning: network IP
# this model is intended to minimize the total cost of investing in a set of production facilities, and investing in a set of waste facilities, to supply a set of consumers, and dispose all production waste

# ---- define set(s) ----

set N;    # set of all nodes (ie. consumers, facilities, wastes)
set A := N cross N;    # set of arcs
set M;    # set of materials (ie. product, waste)
set C;    # set of consumers
set F;    # set of facilities
set W;    # set of wastes

# ---- define parameter(s) ----

param net{N,M} default 0;    # net flow of material at a node
param d{(i,j) in A} default 0;    # arc distance
param cap{(i,j) in A} default 0;    # arc material flow capacity
param seta{(i,j) in A} := 500 + (0.30 * d[i,j]);    # cost to use (ie. setup) an arc
param setf{F};    # cost to setup a facility
param setw{W};    # cost to setup a waste
param con{F};    # conversion constant (ie. how much waste is produced for every unit of product)
param c{M};    # material travel unit cost

# ---- define variable(s) ----

var openf{F} binary;    # a facility is/isnt setup
var openw{W} binary;    # a waste is/isnt setup
var opena{(i,j) in A} binary;    # an arc is/isnt setup
var x{(i,j) in A, M} >= 0;    # material flow on an arc

# ---- define objective function(s) ----

minimize Cost: sum{i in F}(setf[i] * openf[i]) + sum{i in W}(setw[i] * openw[i]) + sum{(i,j) in A: i < 11 and j < 11}(seta[i,j] * opena[i,j]) + sum{(i,j) in A, k in M}(c[k] * d[i,j] * x[i,j,k]);

# ---- define constraint(s) ----

s.t. Demand{i in C, k in M}: sum{(n,i) in A}(x[n,i,k]) - sum{(i,j) in A}(x[i,j,k]) = net[i,k];
s.t. Production{i in F, k in M}: sum{(n,i) in A}(x[n,i,k]) - sum{(i,j) in A}(x[i,j,k]) >= net[i,k] * openf[i];
s.t. Disposal{i in W, k in M}: sum{(n,i) in A}(x[n,i,k]) - sum{(i,j) in A}(x[i,j,k]) <= net[i,k] * openw[i];
s.t. Capacity{(i,j) in A}: sum{k in M}(x[i,j,k]) <= cap[i,j] * opena[i,j];
s.t. Conversion{i in F}: sum{(i,j) in A}(x[i,j,2]) = sum{(i,j) in A}(con[i] * x[i,j,1]);

# ---- assumptions ----

# there is a (500 + 0.30*model.d[i,j]) usage cost from the perspective of the arcs, not the facilities.. so if two facilities use one arc, there is one usage cost not two usage costs for that particular arc