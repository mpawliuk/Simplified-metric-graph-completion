###############################################################################
### Stuff for computers  ######################################################
###############################################################################

#########################
### 1. For parameters ###
#########################

def is_acceptable(parameters):
    """ Check if parameters are acceptable.

    See first paragrpah of the paper.
    """
    delta, C, K1 = parameters[0:3]
    if delta < 2:
        return False
    if not (K in range(1,delta + 1)):
        return False
    if not (C in range(2*delta + K + 1, 3*delta+2)):
        return False
    return True

def max_magic_number(parameters):
    """Return the maximal magic number if it exists. Definition 2.2."""
    delta, C, K = parameters[0:3]

    # x // 2 takes floor of divsion.
    # -(-x // 2) takes ceiling of division.
    M1 = max(K, -(-delta // 2))
    M2 = (C - delta - 1) // 2

    assert M1 <= M2
    return M2

##############################
### 2. All about triangles ###
##############################

def make_triangles(delta):
    """Return all possible triangles (good and bad).

    Output format is [length 1, length 2, length 3, "Good/bad"]
    Written in nondecreasing order.
    """
    triangles = []
    for i in range(1,delta+1):
        for j in range(i,delta+1):
            for k in range(j,delta+1):
                triangles.append([i,j,k,""])
    return triangles

def make_forbidden_triangles(parameters):
    """Return all forbidden triangles."""
    delta, C, K = parameters[0:3]
    all_triangles = [x for x in make_triangles(delta)]

    forbidden_triangles = [] # This is where we store the bad triangles.

    for triangle in all_triangles:
        p = triangle[0]+triangle[1]+triangle[2] # The perimeter of the triangle.
        p_parity = p % 2 # The parity of the perimeter.
        m = triangle[0] # This is the minimum side length, it's already sorted!

        # Check the triangle inequality.
        # (only need to check that the biggest side can't be reached)
        if (triangle[2] > triangle[1]+triangle[0]): #Triangle inequality
            triangle[3] = "Metric"
            forbidden_triangles.append(triangle)
        elif not (p < C):
            triangle[3] = "C"
            forbidden_triangles.append(triangle)
        elif (p_parity == 1) and (p < 2*K + 1):
            triangle[3] = "Odd, K"
            forbidden_triangles.append(triangle)
    return forbidden_triangles

def contains_forbidden_triangles(graph, parameters):
    """Check if the graph has a forbidden triangle using brute force."""
    delta, C, K = parameters[0:3]
    forb = [x[:3] for x in make_forbidden_triangles(parameters)]
    vertices = range(len(graph.vertices()))
    for i in vertices:
        for j in vertices[i+1:]:
            for k in vertices[j+1:]:
                vi,vj,vk = graph.vertices()[i], graph.vertices()[j], graph.vertices()[k]
                lab1 = int(graph.edge_label(vi,vj))
                lab2 = int(graph.edge_label(vj,vk))
                lab3 = int(graph.edge_label(vi,vk))
                if sorted([lab1, lab2, lab3]) in forb:
                    return ((i,j,k), sorted([lab1, lab2, lab3]))
    return False

def is_complete(graph):
    """Check if a labelled grpah is complete."""
    return not graph.complement().edges(labels=False)

####################
### 3. For forks ###
####################

def generate_forks(parameters):
    """Return a list with elements of the form [(i,j),a,b,c, *_ ].

    a,b,c,*_ are the ways to complete the fork i,j.
    """
    forb = [x[:3] for x in make_forbidden_triangles(parameters)]
    delta = parameters[0]
    forks = []

    for i in range(1,delta+1):
        for j in range(i,delta+1):
            acceptable=[(i,j)]
            for k in range(1,delta+1):
                if sorted([i,j,k]) not in forb:
                    acceptable.append(k)
            if len(acceptable)>1:
                forks.append(acceptable)
    return forks

def sort_forks(parameters):
    """Return a list of the form [F(0),F(1), ..., F(delta)].

    -- F(i) will be the list of things to be completed by distance i.
    See paragraph after Observation 2.3.
    """
    delta = parameters[0]
    M = max_magic_number(parameters)
    forks_by_completion = [[] for i in range(delta+1)]

    for fork in generate_forks(parameters):
        l = fork[0][0] #left fork
        r = fork[0][1] #right fork, note r>=l

        #Is the magic number in there?
        if M in fork[1:]:
            forks_by_completion[M].append(fork[0]) # Magic distance
        elif l+r < M and l+r in fork[1:]:
            forks_by_completion[l+r].append(fork[0]) # Small geodesic
        elif r-l > M and r-l in fork[1:]:
            forks_by_completion[r-l].append(fork[0]) # Big geodesic
        else:
            forks_by_completion[max(fork[1:])].append(fork[0]) # C bound, add maximal thing allowed
    return forks_by_completion

def find_forks(graph, i,j):
    """Find all forks in the graph with labels i,j.

    The output elements are of the form [v,a,b],
    where v is the centre of the fork and there is no edge between a and b
    """
    forks = []
    for edge in graph.edges():
        #First find an edge with label i
        if edge[2] == str(i):
            for endpoint in edge[:2]:
                #Now look for an edge with label j coming from one of the endpoints
                for nghbr in graph.neighbors(endpoint):
                    if graph.has_edge(endpoint,nghbr, str(j)):
                        P = graph.subgraph(list(edge[:2])+[nghbr])
                        if len(P.edges()) == 2:
                            #now keep track of the missing edge
                            for vP in P.vertices():
                                if len(P.neighbors(vP)) == 2:
                                    info = [vP] + P.neighbors(vP)
                                    if info not in forks:
                                        forks.append(info)
    for edge in graph.edges():
        #Find an edge with label j
        if edge[2] == str(j):
            for endpoint in edge[:2]:
                #Now look for an edge with label j coming from one of the endpoints
                for nghbr in graph.neighbors(endpoint):
                    if graph.has_edge(endpoint,nghbr, str(i)):
                        P = graph.subgraph(list(edge[:2])+[nghbr])
                        if len(P.edges()) == 2:
                            #now keep track of the missing edge
                            for vP in P.vertices():
                                if len(P.neighbors(vP)) == 2:
                                    info = [vP] + P.neighbors(vP)
                                    if info not in forks:
                                        forks.append(info)
    return forks

def time_sort(parameters):
    """Return a list of the order in which we add edges.

    See comments after Observation 2.3, and see figure 3.
    """
    delta = parameters[0]
    M = max_magic_number(parameters)

    temp_list = []
    for x in range(1,M):
        temp_list.append([x, 2*x - 1])
    for x in range(M+1, delta):
        temp_list.append([x, 2*(delta - x)])

    return [i[0] for i in sorted(temp_list, key=lambda y:y[1])]

######################
### 4. Delta stuff ###
######################

def is_delta_graph(graph, parameters):
    """Check if a graph has no labels greater than delta."""
    if graph.edge_labels():
        return max([int(x) for x in graph.edge_labels()]) <= parameters[0]
    else:
        return True

#######################
### 5. For Printing ###
#######################

def display_highlighted_edges(graph, delta, edge_label):
    """Show a graph with newly added edges in black."""
    d = {str(i):rainbow(delta + 1)[i] for i in range(1, delta + 1)}
    d[edge_label] = 'black'
    graph.graphplot(edge_labels=True, color_by_label=d, layout='circular').show()
    return None

#############################
### 6. The major function ###
#############################

def complete_partial_graph(G_input, parameters, display_all_steps=False, display_recursive_steps=False):
    """Return the completed graph, subject to the parameters.

    3. Complete forks as perscribed.
    4. Add magic distance (+- 1) to finish.
    --4.1. Print step 4.
    """
    G_output = copy(G_input)

    delta, C, K = parameters[0:3]
    delta_parity = parameters[0]%2
    M = max_magic_number(parameters)

    if display_all_steps and not is_delta_graph(G_input, parameters):
        print "The input graph has labels larger than ", delta, ". It will not run."
        return Graph()

    #########################
    ### 1. Complete forks ###
    #########################

    # This needs to be ordered by time
    for t in time_sort(parameters):
        added_something = False
        for fork_rule in sort_forks(parameters)[t]:
            # Things that get value t
            for fork_to_fill in find_forks(G_output,fork_rule[0],fork_rule[1]):
                # fork_to_fill looks like [v, a, b] where v is the vertex of the fork
                G_output.add_edge((fork_to_fill[1],fork_to_fill[2],str(t)))
                added_something = True
        if display_all_steps and added_something:
            print "Added edges with weight: ", t
            display_highlighted_edges(G_output, delta, str(t))
        elif display_all_steps:
            print "No edges added with weight: ", t
    ################################
    ### 2. The final step adds M ###
    ################################
    for pair_of_vertices in G_output.complement().edges(labels=False):
        x = pair_of_vertices[0]
        y = pair_of_vertices[1]
        # For every other non-edge add the Magic distance
        G_output.add_edge((x,y,str(M)))

    ##################################
    #### 2.1 Print steps if needed ###
    ##################################
    if display_all_steps and not is_complete(G_output):
        print "Add the magic distances " + str(M) + " to finish."

    ##############################
    ### Output completed graph ###
    ##############################
    return G_output

def display_graph_completion(G_input, parameters, display_all_steps):
    """Print the run of the algorithm."""

    if display_all_steps:
        print "The parameters are:"
        print "   delta = ", parameters[0]
        print "   C = ", parameters[1]
        print "   K = ", parameters[2]
        print "--------------------"
        print "Is the starting graph connected?", G_input.is_connected()
        print "--------------------"
        print "Edges of a given distance will be added in order: ", time_sort(parameters)
        print "then the magic distance: ", max_magic_number(parameters)
        print "--------------------"

    print "Here is the starting graph:"
    colours = {str(i):rainbow(parameters[0]+1)[i] for i in range(1,parameters[0]+1)}
    G_input.graphplot(edge_labels=True, color_by_label=colours, layout='circular').show()

    G_complete = complete_partial_graph(G_input, parameters, display_all_steps)

    if contains_forbidden_triangles(G_complete, parameters):
        print "Uh oh! The completed graph has a forbidden triangle!"
        print "The vertices: ", contains_forbidden_triangles(G_complete, parameters)[0]
        print "make the forbidden triangle: ", contains_forbidden_triangles(G_complete, parameters)[1]
    else:
        print "This graph has no forbidden triangles."

    print "--------------------"
    print "Here is the completed graph:"
    return G_complete.graphplot(edge_labels=True, color_by_label=colours, \
                                layout='circular').show()

############################################################################
### 7. Stuff for humans  ###################################################
############################################################################

sample_parameters = [6, 15, 2] # Example 2.5, Figure 4, 5 and Table 1.

def graph_sample(n):
    """Return a premade graph

    n should be 1 or 2.
    Graph 1 can be completed using the sample parameters
    Graph 2 can't be completed using the sample parameters, but the
    algorithm will try its best.
    """
    # A graph with one node.
    G_sample_0 = Graph(1)

    # This a 11466 triangle from Figure 5
    G_sample_1 = Graph()
    G_sample_1.add_edges([(0, 1, "1"), (1, 2, "1"), (2, 3, "4"), (3, 4, "6"), (4, 0, "6")])

    # This a 11566 triangle from Figure 7
    # Don't expect this to be completed!
    G_sample_2 = Graph()
    G_sample_2.add_edges([(0, 1, "1"), (1, 2, "1"), (2, 3, "5"), (3, 4, "6"), (4, 0, "6")])

    graph_samples = [G_sample_0, G_sample_1, G_sample_2]

    return graph_samples[n%len(graph_samples)]

#######################################
### 7.1 CHOOSE YOUR PARAMETERS HERE ################################################
#######################################

parameters_start = sample_parameters

###########################################
### 7.2 CHOOSE YOUR STARTING GRAPH HERE ###########################################
###########################################

G_start = graph_sample(2)

############################################################
### 7.3 Do you want all steps displayed? (True or False) ##########################
############################################################

display_all_steps_start = True

###############################
### 7.4 The function call ##########################
###############################

display_graph_completion(G_start, parameters_start, display_all_steps_start)
