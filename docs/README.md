# Study tracks

Self-directed reading/build lists. Each is staged — every stage ends with
something that runs, and the order matters more than the volume.

- **[Build Your Own Lisp](build-your-own-lisp.md)** — from McCarthy's `eval` in
  seven primitives, through mal / SICP / *Lisp in Small Pieces*, to a compiler
  and a garbage collector.
- **[Build Your Own OS](build-your-own-os.md)** — from a booting VGA "hello"
  through interrupts, paging, and user mode, to reading xv6 end to end.

The two meet at the end of the OS track (Lisp machines, Mezzano, Loko Scheme,
Project Oberon) — worth reading even if you only pursue one.

## Where this repo fits

| You want to practice | Use |
|---|---|
| Writing an interpreter | `lisp/eliza.lisp` — pattern matcher + rule engine, ~300 lines, no dependencies. Extend the rule format, then the matcher. |
| Hosting a Lisp on someone else's VM | The `erlang/` + `src/` OTP code, plus LFE (Lisp Flavoured Erlang), which compiles to BEAM bytecode. |
| Bare-metal / freestanding code | `zig/` — Zig cross-compiles to `x86_64-freestanding-none` with no toolchain build, which is the shortest path from this repo to a booting kernel. |
| OS concepts in userland | The OTP supervision trees here *are* process isolation, scheduling, and restart policy. Read *The BEAM Book* alongside OSTEP. |
