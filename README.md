# mini_ai

Erlang OTP mini AI + new Elixir OTP twin.
Related case study: https://github.com/Azdwarf5Azdwarf/wef-cyber-polygon-case-study

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
