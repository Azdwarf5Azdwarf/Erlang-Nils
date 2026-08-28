# mini_ai

Erlang OTP mini AI + new Elixir OTP twin, with a local Lisp ELIZA as the
offline `[help]` front end.
Related case study: https://github.com/Azdwarf5Azdwarf/wef-cyber-polygon-case-study

## [help] — ELIZA (main script)

The default way to talk to this project. Pure Common Lisp, no API key, no
network — Weizenbaum's DOCTOR script over a segment-variable pattern matcher.

```bash
sbcl --script lisp/eliza.lisp
```

```
ELIZA: Hello. What is on your mind?
YOU:   I am stuck on my kernel project.
ELIZA: How long have you been stuck on your kernel project?
```

From a REPL, `(help)` is the entry point:

```lisp
(load "lisp/eliza.lisp")   ; starts a session immediately
(help)                     ; ...or start another one
```

To load it as a library instead (embedding, tests), suppress the autostart:

```lisp
(defparameter cl-user::*eliza-autostart* nil)
(load "lisp/eliza.lisp")
(eliza::respond (eliza::read-input "I want a new job"))
;; => (WHAT WOULD IT MEAN IF YOU GOT A NEW JOB)
```

Rules live in `eliza::*rules*` — `(pattern response...)`, first match wins,
response picked at random. `(?* ?x)` matches any run of words.

## Erlang
```bash
export OPENAI_API_KEY=sk-...
rebar3 shell
mini_ai_server:ask("Hello").
```

## Elixir (new)
```bash
cd elixir
export OPENAI_API_KEY=sk-...
mix deps.get
iex -S mix
MiniAi.ask("Hello")
```

Same idea: supervised GenServer calls OpenAI chat completions.

## Study tracks

Reading lists in [`docs/`](docs/): [build your own Lisp](docs/build-your-own-lisp.md),
[build your own OS](docs/build-your-own-os.md).
