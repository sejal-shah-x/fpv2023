import AutograderLib
import LoVe.LoVelib

/- # FPV Homework 7: Mathematical Structures

Homework must be done in accordance with the course policies on collaboration
and academic integrity.

Replace the placeholders (e.g., `:= sorry`) with your solutions. When you are
finished, submit *only* this file to the appropriate Gradescope assignment.
Remember that the autograder does not determine your final grade. -/


namespace LoVe

/- ## Question 1 (6 points + 1 bonus point): Graph Definitions

There are many definitions of *graphs* in both the math and CS literature.
Graphs have *vertices* (or *nodes*) which are connected by *edges*. Some
definitions specify edges to be *directed*, i.e., an edge that connects vertex
`a` to vertex `b` does not connect `b` to `a`. Others are undirected. Some allow
*loops*, i.e. edges from a vertex `a` to itself. Some don't.

A graph can be defined as a set of vertices along with a list of tuples of
vertices `(v, v')` representing edges connecting `v` to `v'`: -/

structure ListGraph (V : Type) :=
  (edges : List (V × V))

/- For large graphs, this data structure can get cumbersome. Instead, we can
define graphs based on an *adjacency predicate*. Since we'll be interested in
undirected, loopless graphs, we'll need to ensure undirectedness and
looplessness by proving that our adjacency predicate is symmetric and
irreflexive, respectively. -/

structure PredGraph (V : Type) :=
  (adj : V → V → Prop)
  (symm : Symmetric adj)
  (loopless : Irreflexive adj)

/- 1.1 (2 points). A complete graph is a graph in which each vertex is adjacent
to each other vertex. Define the complete graph on four vertices, K₄, as a
`ListGraph` and as a `PredGraph`. You can use a predefined predicate for the
adjacency predicate, or you can make your own! -/

inductive Quad : Type
| one | two | three | four

-- Feel free to ignore these lines
deriving instance Repr for ListGraph
deriving instance Repr for Quad

section
open Quad

def K₄_quad_lg : ListGraph Quad :=
  ListGraph.mk [(one, two), (one, three), (one, four),
    (two, one), (two, three), (two, four),
    (three, one), (three, two), (three, four),
    (four, one), (four, two), (four, three)
  ]

def adj_pred (x y : Quad) : Prop :=
  x ≠ y

def K₄_quad_pg : PredGraph Quad :=
  @PredGraph.mk Quad adj_pred
  (by
    rw [Symmetric]
    intro x y
    rw [adj_pred]
    intro axy
    rw [adj_pred]
    aesop
    done)
  (by
    rw [Irreflexive]
    intro x
    rw [adj_pred]
    aesop
    done)

end

/- 1.2 (3 points). If we choose the right type for a graph, it can be easier to
define, manipulate, and manage the graph. A *cycle graph* is a graph with
vertices v₁,...,vₙ whose only edges are connecting vᵢ and vᵢ₊₁ for i < n as well
as vₙ to v₁. Here's a visual representation of a cycle graph on six vertices:

     v₆    v₁
      • -- •
     /      \
 v₅ •        • v₂
     \      /
      • -- •
     v₄     v₃

Define a cycle graph `C₅` on the type `Fin 5` by designing a symmetric and
irreflexive predicate. You'll need to prove symmetry and irreflexivity, too!

Note: Be careful with addition on `Fin 5`. You might recognize this type
mathematically as ℤ/5ℤ.
-/

#check Fin
#eval (4 : Fin 5) + 1

/- You also might be surprised that tactics like `linarith` don't work on
`Fin 5`. Turns out that algorithm doesn't like it when `5 = 0`! If you end up
with a hypothesis `h : 0 = 1` or something like that, `cases h` may come in
handy. -/

def C₅ : PredGraph (Fin 5) :=
  sorry

/- 1.3 (1 point). Using this functional definition of a graph, we can easily
generalize the above cycle graph to make an arbitrarily large cycle. Fill in the
following definition, mirroring your previous definition. -/

def C₁₀₀ : PredGraph (Fin 100) :=
  sorry

/- Food for thought: how could we define `C₁₀₀` as a `ListGraph` without typing
out 100 tuples? -/



/- 1.4 (**optional**, 1 bonus point). We lied a bit: the definitions `ListGraph`
and `PredGraph` are actually capturing slightly different graph concepts!

To make that more precise: we can state the *equivalence* of a `ListGraph` and a
`PredGraph`. We call two representations *equivalent* when they are defined on
the same collection of vertices and -- according to each way of representing
adjacency -- the same vertices are adjacent in each. -/

def GraphEquiv {α : Type} (lg : ListGraph α) (fg : PredGraph α) : Prop :=
  ∀ v₁ v₂ : α, fg.adj v₁ v₂ ↔ ((v₁, v₂) ∈ lg.edges)

/- Provide an example of two non-equal `ListGraph`s that are equivalent to the
same `PredGraph`. Prove that your example satisfies these conditions. For those
who've studied a bit of graph theory: What graph theory concept is appearing
here? (We won't grade your answer to this last question.)

Note: The two `ListGraph`s you pick should not be permutations of each other --
these are "boring" examples. So, for instance, don't pick `[(v₁, v₂), (v₂, v₁)]`
and `[(v₂, v₁), (v₁, v₂)]` for some distinct values `v₁` and `v₂`.

Hint for the proof: you can use `tac₁ <;> tac₂` to apply `tac₂` to all goals
generated by `tac₁`. You don't have to use this, but it might make your life
easier. -/

-- Write your answer here


/- For question 2 below, you may chose to do **one** of Question 2α or Question
2β. You may do both, but only one will be graded. Please clearly indicate which
one you want to be graded.

Each question sketches an extension of the graph-theoretic groundwork laid in
question 1: 2α a more mathematical one, 2β a more computational one. -/


/- ## Question 2α : Automorphism Groups of Graphs (8 points)

An automorphism of a graph is a function on (or permutation of) its vertices
that preserves the edge structure of the graph. In other words: -/

def IsGraphAutomorphism {α : Type} (G : PredGraph α) (A : α → α) : Prop :=
  ∀ (v₁ v₂ : α), G.adj v₁ v₂ ↔ G.adj (A v₁) (A v₂)

/- We can define a structure like this to define an automorphism of a graph. -/
structure GraphAutomorphism (α : Type) (G : PredGraph α) :=
  (f : α → α)
  (is_aut : IsGraphAutomorphism G f)


/- Let's focus on a particular graph, say, the graph `C₅` defined above, to
define and study its automorphisms. It has ten automorphisms: five "flips,"
where we mirror the graph across some axis, and five "rotations," where we
"rotate" the vertices by some number of spots. (Note that we take the identity
map to be a trivial rotation). Here's an example of each:

Flip across the vertical:
        v₀                         v₀
        •                          •
     /     \                    /     \
 v₄ •       • v₁     -->    v₁ •       • v₄
     \     /                    \     /
      • - •                      • - •
     v₃   v₂                    v₂   v₃

Clockwise rotation by two vertices:
        v₀                         v₃
        •                          •
     /     \                    /     \
 v₄ •       • v₁     -->    v₂ •       • v₄
     \     /                    \     /
      • - •                      • - •
     v₃   v₂                    v₁   v₀

2α.1 (2 points). Define a function `C₅_rotate` below such that `C₅_rotate n`
corresponds to an clockwise rotation by `n` vertices. Then define a function
`C₅_flip` such that `C₅_flip n` corresponds to the flip that fixes vertex `n`
and flips all the rest (convince yourself that all flips are of this form!).

Hint: we strongly suggest you express both functions as closed-form formulas.
Try to make your formulas as simple as possible. -/

def C₅_rotate (n : Fin 5) : Fin 5 → Fin 5 :=
  sorry

def C₅_flip (n : Fin 5) : Fin 5 → Fin 5 :=
  sorry

/- 2α.2 (2 points). Now prove that these functions are indeed automorphisms.

Hint: If it seems like you aren't able to simplify complicated expressions in
your proofs using tactics like `simp`, see if you can simplify your definitions
of the automorphisms above. -/

@[autograded 1]
theorem C₅_rotate_is_aut : ∀ n, IsGraphAutomorphism C₅ (C₅_rotate n) :=
  sorry

@[autograded 1]
theorem C₅_flip_is_aut : ∀ n, IsGraphAutomorphism C₅ (C₅_flip n) :=
  sorry

/- Now we can define the elements of our structure! -/
def C₅_rotate_aut (n : Fin 5) : GraphAutomorphism (Fin 5) C₅ := {
  f := C₅_rotate n
  is_aut := C₅_rotate_is_aut n
}

def C₅_flip_aut (n : Fin 5) : GraphAutomorphism (Fin 5) C₅ := {
  f := C₅_flip n
  is_aut := C₅_flip_is_aut n
}

/- Graph automorphisms under the operation of function composition form a group!
Let's work towards building that group for our path₅ graph. -/

/- 2α.3 (2 points). First, let's prove that automorphisms are closed under
composition (`aut_comp_aut`). Then we'll define the composition function as
`autComp`.

Hint for the lemma: `Iff.trans` might be handy!
-/

@[autograded 1]
lemma aut_comp_aut {α : Type} (G : PredGraph α) (f g : α → α) :
  IsGraphAutomorphism G f →
  IsGraphAutomorphism G g →
  IsGraphAutomorphism G (f ∘ g) :=
  sorry

def aut_comp {α : Type} (G : PredGraph α) :
 GraphAutomorphism α G → GraphAutomorphism α G → GraphAutomorphism α G :=
  sorry

-- We define convenience notation for the composition operation on the
-- automorphism group of `path₅`
infixl:90 " ∘₅ " => aut_comp C₅

/- 2α.4 (2 points). Now prove that this operation is associative and define an
inverse function.

Hint for the inverse: how many times do you need to apply an arbitrary rotation
to be *guaranteed* to get back to the original graph? How many times for an
arbitrary rotation? -/

@[autograded 1]
lemma GraphAutomorphism.assoc :
  ∀ (a b c : GraphAutomorphism (Fin 5) C₅), a ∘₅ b ∘₅ c = a ∘₅ (b ∘₅ c) :=
  sorry

-- Note: You **do not** need to provide the `is_aut` field for the value you
-- return; feel free to `sorry` that proof.
def GraphAutomorphism.inv :
  GraphAutomorphism (Fin 5) C₅ → GraphAutomorphism (Fin 5) C₅ :=
  sorry

/- You don't have to prove the rest, but if you did, you'd have a group! (If
you've studied some group theory, see if you can identify which group this is.)

Notice also how easy it would be to generalize this group to an automorphism
group of any cycle graph. -/

axiom GraphAutomorphism.one_mul :
  ∀ (a : GraphAutomorphism (Fin 5) C₅), (C₅_rotate_aut 0) ∘₅ a = a
axiom GraphAutomorphism.mul_one :
  ∀ (a : GraphAutomorphism (Fin 5) C₅), a ∘₅ (C₅_rotate_aut 0) = a
axiom GraphAutomorphism.mul_left_inv :
  ∀ (a : GraphAutomorphism (Fin 5) C₅),
  GraphAutomorphism.inv a ∘₅ a = C₅_rotate_aut 0

@[instance] def AutomorphismGroup_C₅ :
  Group (GraphAutomorphism (Fin 5) C₅) := {
  mul := aut_comp C₅,
  one := C₅_rotate_aut 0,
  mul_assoc := GraphAutomorphism.assoc,
  one_mul := GraphAutomorphism.one_mul,
  inv := GraphAutomorphism.inv,
  mul_one := GraphAutomorphism.mul_one,
  mul_left_inv := GraphAutomorphism.mul_left_inv,
}


/- ## Question 2β : Computer Networks (8 points)

Computer networks can be modeled by graphs. Suppose we have a system of routers,
and we want any router to be able to send and receive information from any other
router. Graph-theoretically, we say that we want our graph to be *connected*.
-/

/- 2β.1 (2 points). We'll say a *path* through a graph -- represented as a list
of vertices -- is valid if it:
* Starts with the starting vertex `startV`
* Ends with the ending vertex `endV`
* For each element in the list vᵢ, vᵢ₊₁ is adjacent to vᵢ

Fill in the predicate `IsPath` such that `IsPath G v₁ v₂ vs` holds just when
`vs` is a valid path from `v₁` to `v₂` in `G`.
-/

inductive IsPath {α : Type} : PredGraph α → α → α → List α → Prop
-- Fill this in!

-- A graph is connected if there is a path between any two distinct vertices
def IsConnected {α : Type} (G : PredGraph α) : Prop :=
  ∀ (v₁ v₂ : α), v₁ ≠ v₂ → ∃ p, IsPath G v₁ v₂ p

/- Suppose now that Rob, infamous for hating routers, destroys one of the
routers. It's very much possible that the destruction of that router
disconnected the rest of the network, i.e., after that router is destroyed,
there are some routers that can no longer communicate with others. We would call
that router a **separation vertex**. We might consider employing the stricter
condition of **biconnectivity** to avoid this problem. Biconnectivity is when
there are no separation vertices in the graph, or, alternatively, for every two
vertices there are two disjoint paths connecting them. -/

/- 2β.2 (2 points). Write an inductive predicate that holds when two lists are
totally disjoint (i.e., they have no elements in common).

Hint: you may find the predicate `x ∈ xs` useful! -/

inductive ListDisj {α : Type} : List α → List α → Prop
-- Fill this in!

/- 2β.3 (2 points). Use the predicate above to write a definition for
biconnectivity. -/

def IsBiconnected {α : Type} (G : PredGraph α) : Prop :=
  sorry

/- 2β.4 (2 points). Prove that the complete graph `K₄_fin` defined below is
biconnected. -/

def K₄_fin : PredGraph (Fin 4) :=
  ⟨(·≠·),  -- This is shorthand for `(λ x y => x ≠ y)`
   λ _ _ => ne_comm.mp,
   λ _ h => h rfl⟩

-- You can disregard these declarations (they're just to help us prove
-- `exist_distinct_fin4_of_neq`)
lemma neq_fin4_of_neq (a b : ℕ) {ha : a < 4} {hb : b < 4} :
  a ≠ b → (⟨a, ha⟩ : Fin 4) ≠ (⟨b, hb⟩ : Fin 4) :=
  by intro _ h; cases h; contradiction
macro "fin_neq" : tactic =>
  `(tactic| repeat (first | apply And.intro | apply neq_fin4_of_neq | trivial))

-- You will likely find this lemma useful in your proof!
lemma exist_distinct_fin4_of_neq :
  ∀ x y : Fin 4, x ≠ y → ∃ a b : Fin 4, x ≠ a ∧ a ≠ y ∧ x ≠ b ∧ b ≠ y ∧ a ≠ b
  | ⟨0, _⟩, ⟨0, _⟩, h => absurd rfl h
  | ⟨0, _⟩, ⟨1, _⟩, _ => ⟨2, 3, by fin_neq⟩
  | ⟨0, _⟩, ⟨2, _⟩, _ => ⟨1, 3, by fin_neq⟩
  | ⟨0, _⟩, ⟨3, _⟩, _ => ⟨1, 2, by fin_neq⟩
  | ⟨1, _⟩, ⟨0, _⟩, _ => ⟨2, 3, by fin_neq⟩
  | ⟨1, _⟩, ⟨1, _⟩, h => absurd rfl h
  | ⟨1, _⟩, ⟨2, _⟩, _ => ⟨0, 3, by fin_neq⟩
  | ⟨1, _⟩, ⟨3, _⟩, _ => ⟨0, 2, by fin_neq⟩
  | ⟨2, _⟩, ⟨0, _⟩, _ => ⟨1, 3, by fin_neq⟩
  | ⟨2, _⟩, ⟨1, _⟩, _ => ⟨0, 3, by fin_neq⟩
  | ⟨2, _⟩, ⟨2, _⟩, h => absurd rfl h
  | ⟨2, _⟩, ⟨3, _⟩, _ => ⟨0, 1, by fin_neq⟩
  | ⟨3, _⟩, ⟨0, _⟩, _ => ⟨1, 2, by fin_neq⟩
  | ⟨3, _⟩, ⟨1, _⟩, _ => ⟨0, 2, by fin_neq⟩
  | ⟨3, _⟩, ⟨2, _⟩, _ => ⟨0, 1, by fin_neq⟩
  | ⟨3, _⟩, ⟨3, _⟩, h => absurd rfl h

@[autograded 2]
theorem K₄_fin_is_biconnected : IsBiconnected K₄_fin :=
  sorry

end LoVe
