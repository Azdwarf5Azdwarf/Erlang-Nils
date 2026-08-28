# Build Your Own Lisp — study track

A staged reading/build list. Each stage ends with something that runs. Don't
read ahead of what you've built; the books get much easier once you've written
the thing they're describing.

---

## Stage 0 — Get the idea in one sitting (a weekend)

| Resource | What you get |
|---|---|
| Paul Graham, **The Roots of Lisp** — <https://www.paulgraham.com/rootsoflisp.html> | McCarthy's `eval` in seven primitives. The whole trick of Lisp in ~10 pages. Read it twice. |
| John McCarthy (1960), **Recursive Functions of Symbolic Expressions…** — <https://www-formal.stanford.edu/jmc/recursive.html> | The original paper. Short. Read after Graham's version. |
| Peter Norvig, **(How to Write a Lisp Interpreter in Python)** — <https://www.norvig.com/lispy.html> | ~90 lines, working Scheme. Then **lispy2** (<https://www.norvig.com/lispy2.html>) adds macros, tail calls, call/cc. |

**Milestone:** type Norvig's `lis.py` in *by hand* (don't paste), then extend it with
`let`, `cond`, and string literals on your own.

---

## Stage 1 — Your first real implementation

Pick **one** and finish it. Finishing beats breadth here.

- **Make-A-Lisp (mal)** — <https://github.com/kanaka/mal> — the best-structured
  path. 11 incremental steps, each with a guide, a test suite, and ~90 reference
  implementations you can peek at *after* you're stuck. Do it in a language you
  already know (Elixir/Erlang and Zig implementations both exist in-tree there —
  useful given this repo).
- **Build Your Own Lisp** (Daniel Holden) — <https://buildyourownlisp.com/> —
  free online book, C, teaches you C along the way. Caveat: its `mpc` parser
  combinator library does a lot of the work for you, and its Lisp is not a
  Scheme/CL dialect. Great if you want C practice; use mal if you want fidelity.
- **Crafting Interpreters** (Bob Nystrom) — <https://craftinginterpreters.com/> —
  not a Lisp, but the clearest book ever written on tree-walking interpreters
  (part I) and bytecode VMs + GC (part II). If any concept in mal confuses you,
  the answer is in here.

**Milestone:** a REPL that runs a recursive `fib`, supports closures, and has
`quote`/`quasiquote` working correctly.

---

## Stage 2 — Understand what you built

- **SICP**, chapters 4–5 — <https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html>
  - Ch. 4.1: the **metacircular evaluator** — Lisp in Lisp. Then 4.2 (lazy),
    4.3 (nondeterministic `amb`), 4.4 (logic programming).
  - Ch. 5: the **explicit-control evaluator** and a register machine — this is
    where an interpreter turns into a compiler.
  - Video lectures (Abelson & Sussman, 1986): <https://ocw.mit.edu/courses/6-001-structure-and-interpretation-of-computer-programs-spring-2005/video_galleries/video-lectures/>
- **Lisp in Small Pieces** (Christian Queinnec) — the deep one. Builds 11
  interpreters and 2 compilers, and is the definitive treatment of
  environments, dynamic vs. lexical scope, continuations, and macro hygiene.
  Buy this only after Stage 1; it's brutal cold.
- **R7RS-small** — <https://standards.scheme.org/> — the spec is ~90 pages and
  is genuinely readable. Use it as your conformance target.

**Milestone:** implement proper tail calls and `call/cc`, and explain to
yourself why your evaluator needed restructuring to get them.

---

## Stage 3 — Compilation and runtime

- **An Incremental Approach to Compiler Construction** (Abdulaziz Ghuloum) —
  paper + tutorial: <https://github.com/namin/inc>. Scheme → x86 assembly in
  ~24 steps, each producing a working compiler. The single best "compile a Lisp"
  resource that exists.
- **Compiling a Lisp** (Max Bernstein) — <https://bernsteinbear.com/blog/compiling-a-lisp-0/> —
  a modern, well-commented walkthrough of the Ghuloum approach in C.
- **Three Implementation Models for Scheme** (R. Kent Dybvig, PhD thesis) —
  <https://www.cs.indiana.edu/~dyb/papers/3imp.pdf> — heap, stack, and
  string-based models; the foundation under Chez Scheme.
- **Rabbit: A Compiler for SCHEME** (Guy Steele, 1978) and **Compiling with
  Continuations** (Andrew Appel) — CPS conversion, closure conversion.
- Garbage collection:
  - **Baby's First Garbage Collector** (Nystrom) — <https://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/> — mark-sweep in ~100 lines.
  - **The Garbage Collection Handbook** (Jones, Hosking, Moss) — the reference.
    Read the copying-collector and generational chapters.

**Milestone:** compile `(lambda (x) (* x x))` to real machine code, run it, and
have a collector that survives allocating in a loop.

---

## Stage 4 — Read real implementations

Small enough to read end to end:

- **femtolisp** — <https://github.com/JeffBezanson/femtolisp> — ~10k lines of C;
  the Lisp that bootstraps Julia's parser. Excellent code.
- **chibi-scheme** — <https://github.com/ashinn/chibi-scheme> — small, R7RS-conformant.
- **s7** — <https://ccrma.stanford.edu/software/s7/> — one .c file, embeddable.
- **SBCL** — <https://www.sbcl.org/> — when you want to see an industrial CL
  compiler; start with the `sb-c` IR1/IR2 boundary, not the whole thing.

Dialect-specific, and relevant to this repo:

- **LFE — Lisp Flavoured Erlang** — <https://lfe.io/> (Robert Virding). A Lisp
  that compiles to BEAM bytecode; the compiler source is a good, readable
  example of "Lisp on someone else's VM". Book: *LFE — The Complete Guide*
  <https://lfe.io/books/>.
- **Clojure** — if you want to see hosted-Lisp design decisions (persistent data
  structures, EDN, no reader macros) argued explicitly: Rich Hickey's talks,
  esp. *Are We There Yet?* and *Simple Made Easy* — <https://github.com/tallesl/Rich-Hickey-fanclub>.

---

## Stage 5 — If you want to *use* Lisp, not just build one

- **Practical Common Lisp** (Peter Seibel) — free: <https://gigamonkeys.com/book/>
- **The Common Lisp Cookbook** — <https://lispcookbook.github.io/cl-cookbook/>
- **On Lisp** (Paul Graham) — free PDF: <https://www.paulgraham.com/onlisp.html> — macros, hard.
- **Let Over Lambda** (Doug Hoyte) — macro-heavy, opinionated, fun.
- **The Scheme Programming Language** (Dybvig) — free: <https://www.scheme.com/tspl4/>

---

## Traps worth knowing in advance

1. **Don't write a fancy parser first.** S-expressions are 100 lines. The
   interesting part is `eval`. People burn months on tokenizers.
2. **Environments are the whole game.** If closures are wrong, everything above
   them is wrong. Get lexical scope right before adding features.
3. **`quasiquote` is harder than it looks.** Nested unquote-splicing breaks most
   first attempts — mal's step 7 tests will catch you.
4. **Macros:** decide early between naive `defmacro` (easy, unhygienic) and
   `syntax-rules` (hygienic, much harder). Don't try to retrofit hygiene later.
5. **Tail calls are a structural property**, not an optimization you bolt on.
6. **GC before performance.** A leaking interpreter is fine for weeks; then it
   isn't, and by then your allocation sites are everywhere.
