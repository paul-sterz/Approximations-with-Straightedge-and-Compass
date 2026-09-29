# Approximations-with-Straightedge-and-Compass

This project investigates how classical geometric constructions can be used to approximate mathematical quantities that cannot, in general, be constructed exactly with straightedge and compass.

The project combines **computational geometry, numerical optimization, symbolic computation, and algorithmic search**. Starting from a small set of elementary geometric objects, the program systematically explores possible constructions and searches for configurations that produce highly accurate approximations of selected mathematical quantities.

The main targets are:

* $\sqrt{\pi}$ — related to the classical **squaring of the circle**
* $\sqrt[3]{2}$ — related to the classical **Delian problem**
* $\sin(\pi/7)$ — corresponding to the side length of a regular heptagon inscribed in a unit circle

Rather than using conventional numerical approximation methods such as Newton's method, the goal is to obtain the approximations **through geometric constructions themselves**.

---

## 🎥 Visualization

The following visualization shows one of the best constructions found by the computational search.

![Best geometric construction](images/best_construction.png)

---

# 🛠️ Technologies & Methods

## Programming & Tools

The project was primarily implemented in **MATLAB**.

The main tools and techniques used are:

* **MATLAB** for the numerical search, geometric computations, data management, and visualization
* **Symbolic Math Toolbox** for exact/symbolic verification of promising constructions
* **Complex numbers** for representing points in the Euclidean plane
* **Git/GitLab** for version control and experiment management
* Numerical tolerance handling for robust geometric comparisons
* Depth-first search with backtracking for exploring the construction space

The use of complex numbers provides a compact representation of planar geometry: a point $(x,y)$ is represented as the complex number $x+iy$.

---

## Mathematical & Algorithmic Foundations

The core of the project is a **depth-first search through a discrete construction space**.

A construction is represented by a collection of:

* points
* circles
* lines
* distances
* intersections between geometric objects

For circles, the center is represented by a previously constructed point and the radius by a previously constructed distance. In the extended compass-and-ruler setting, previously constructed distances can also be reused as radii independently of their original location.

The algorithm generates new geometric objects, computes their intersections, removes geometrically equivalent objects and points, and recursively continues the construction.

Several mathematical concepts are therefore combined:

* Euclidean geometry
* Circle-circle intersections
* Circle-line intersections
* Line-line intersections
* Complex-number geometry
* Normal forms of lines
* Distance geometry
* Symmetry reduction
* Numerical tolerance and stability
* Symbolic computation
* Depth-first search and backtracking
* Combinatorial search-space reduction

A central challenge is that the number of possible constructions grows extremely rapidly with construction depth. Consequently, a substantial part of the project is devoted to eliminating redundant constructions before they are explored further.

---

# 🔄 The Process

The computational pipeline can be summarized as follows.

### 1. Initialize the construction

The search starts from a small predefined configuration of points, circles, and/or lines.

Symmetries of the initial configuration are exploited to reduce the number of independent starting cases.

### 2. Generate possible geometric objects

At each depth, the algorithm considers possible new constructions.

For circles, different combinations of previously constructed points and distances are examined.

For the ruler-based extension, pairs of points can additionally be connected to form lines.

### 3. Compute intersections

Whenever a new circle or line is created, its intersections with existing geometric objects are calculated.

These intersections form the candidate points for the next construction step.

### 4. Remove redundant constructions

The search space contains a large number of equivalent possibilities.

The program therefore checks for:

* already existing circles
* already existing lines
* duplicate points
* duplicate distances
* geometrically equivalent constructions generated within the same search step

This significantly reduces the number of branches that have to be explored.

### 5. Add newly constructed points and distances

New points are added to the current construction.

All relevant distances between old and newly created points, as well as between newly created points themselves, are evaluated and stored.

These distances can subsequently be reused as geometric quantities, particularly in the compass-with-memory setting.

### 6. Evaluate target quantities

The program continuously compares newly generated distances with the target quantities:

$$
\sqrt{\pi}, \qquad \sqrt[3]{2}, \qquad \sin\left(\frac{\pi}{7}\right).
$$

For every sufficiently good approximation, the complete construction state is stored.

The search therefore does not only return the final numerical approximation, but preserves the complete geometric construction that produced it.

### 7. Symbolically verify promising constructions

The best numerical constructions can subsequently be reconstructed using symbolic mathematics.

Instead of relying exclusively on floating-point arithmetic, the symbolic verification represents quantities such as

$$
\sqrt{3}, \quad \frac{1}{2}, \quad \sqrt{\frac{5}{2}}
$$

in exact symbolic form.

This makes it possible to independently evaluate the final construction and distinguish genuine geometric approximations from numerical artifacts.

---

# 🧠 What I Learned

This project gave me practical experience at the intersection of **mathematics, algorithms, and computational geometry**.

In particular, I worked with:

* Designing algorithms for large combinatorial search spaces
* Implementing geometric algorithms from mathematical definitions
* Representing Euclidean geometry using complex numbers
* Numerical stability and tolerance selection
* Efficient duplicate detection
* Depth-first search and recursive backtracking
* Memory management for computationally intensive searches
* Symmetry reduction
* Symbolic and numerical computation
* Profiling and optimizing computational bottlenecks
* Structuring long-running numerical experiments
* Visualizing and interpreting computationally generated geometric constructions

One of the main lessons was that mathematically simple operations can become computationally expensive when they are embedded in a large search space. Consequently, the efficiency of the **search strategy and pruning mechanisms** can be just as important as the underlying geometric computations.

The project also provided experience in connecting abstract mathematical ideas with concrete computational implementations.

---

# 🚀 How It Can Be Improved

There are several possible directions for further development.

### More efficient search strategies

The current approach relies primarily on depth-first search. More advanced search strategies could prioritize promising constructions instead of exploring branches largely independently.

Possible approaches include:

* heuristic search
* beam search
* randomized search
* evolutionary algorithms
* machine-learning-based branch prioritization

### Better symmetry reduction

Additional geometric symmetries could potentially be detected automatically rather than handled primarily through predefined symmetry-reduced starting configurations.

This could substantially reduce the search space at greater construction depths.

### Parallelization

The search naturally contains independent branches that can potentially be distributed across multiple CPU cores or machines.

A larger-scale distributed implementation could allow significantly deeper searches.

### Improved symbolic verification

The symbolic verification step is computationally expensive for complicated constructions. More specialized algebraic representations or delayed symbolic evaluation could make verification substantially faster.

### Extended construction systems

The framework could be expanded to investigate additional geometric construction models, for example:

* compass-only constructions
* straightedge-only constructions
* compass with memory
* additional reusable geometric quantities
* higher-dimensional geometric constructions

---

# ▶️ Running the Project

## Requirements

* MATLAB
* MATLAB Symbolic Math Toolbox for symbolic verification

## Basic Usage

The numerical search can be started by calling the main function with a maximum construction depth and a starting configuration:

```matlab
mainFinalV3(maxDepth, n)
```

where:

* `maxDepth` specifies the maximum construction depth
* `n` selects one of the symmetry-reduced starting configurations

For the extended compass-and-ruler implementation, the corresponding main function is:

```matlab
mainCompassRuler(maxDepth, n)
```

The program performs a depth-first search and stores the best constructions found during the run.

The symbolic verification can then be applied to selected numerical constructions using:

```matlab
[data_sym, V] = symbolic_construction(data_num);
```

where `data_num` describes a numerically discovered construction.

The resulting symbolic representation can be used to independently evaluate the construction and verify the numerical approximation.

---

## Project Structure

A typical workflow consists of:

```text
Initialization
      ↓
Generate geometric objects
      ↓
Calculate intersections
      ↓
Remove duplicates / symmetries
      ↓
Add new points and distances
      ↓
Evaluate target approximations
      ↓
Store promising constructions
      ↓
Symbolic verification
      ↓
Visualization
```

The project is intended as an exploration of how **classical geometric construction problems can be approached algorithmically** and how computational search can uncover highly accurate geometric approximations that would be difficult to find manually.
