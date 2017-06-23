# Metric-graphs

This README is written for humans. Specifically it is written for humans who aren't great at Python/Sage. The code is very user friendly.

graph_completer.sage is Sage code that goes along with the following mathematical paper:
"COMPLETING GRAPHS TO METRIC SPACES" by ANDRES ARANDA, DAVID BRADLEY-WILLIAMS, ENG KEAT HNG, JAN HUBICKA, MILTIADIS KARAMANLIS, MICHAEL KOMPATSCHER, MATEJ KONECNY, AND MICHEAL PAWLIUK

This code is a simplified version of the code found at:

    https://github.com/mpawliuk/Metric-graphs

The fundamentals are the same, but since this simplified paper only considers a subclass of metric graphs, the code does not need as much infrastructure. The simplified code is easier to read, because there are fewer cases.

You can compile it online, for example, at the free website:

    https://cocalc.com/

# Using the completer

The major function is:

    complete_partial_graph(graph, parameters)

'graph' is any graph without loops or multiedges with integer labels between 1 and delta.

'parameters' is a list of the form: 

    [delta, C, K]

# Preloaded graphs and parameters

There is a set of sample parameters preloaded in the code (line 318).

There are 2 preloaded graphs in the code (lines 320-342). To use them call:

    graph_sample(n)

where n is between 1 or 2.

The preloaded parameters and graphs contain all the ones mentioned in the body of the paper (Figures 5 and 7).

 -----
To make you life even easier you can just choose number m to be 1 or 2 and adjust the following line of the code:

    [line 354] sample_graph_number = m  

# Show me more steps!

By default, the completer will not show steps, but you can add optional arguments to show more:

    complete_partial_graph(graph, parameters, display_all_steps)

'display_all_steps' is True or False. It prints all of the steps in the algorithm or not, together with additional information about the parameters and strategy.

# What is the rest of the code?

The code is divided into sections based on topic.

## Computer Stuff:

### 1. All about parameters

  check that parameters are acceptable, create magic numbers
  
### 2. All about triangles

  Create all triangles, create forbidden triangles, check if graph contains a forbidden triangle
  
### 3. All about forks

  Generate forks, sort them by time, find forks in a graph
  
### 4. Delta stuff

  See if a graph has big labels

### 5. Printing stuff

  Highlight edges when adding new ones
  
### 6. The major function

  The completion algorithm and printing code.
 
## Human Stuff:

7.0 The list of sample graphs and parameters

7.1 The choice of parameters

Either input your own parameters, or use the pre-loaded one.

7.2 The choice of graph

Either input your own graph, or choose an m = 1 or 2 for pre-loaded graphs. (I suggest trying m = 1.)

8.3 Choose whether to display all steps

The defaults are:

    display_all_steps = True

Set this to be False if you want less stuff displayed.

8.4 The function call

That's it!
