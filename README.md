# mini_ai

Erlang OTP mini AI system with supervisor + OpenAI API.

## Run
```bash
export OPENAI_API_KEY=sk-...
rebar3 shell
mini_ai_server:ask("Hello").
```

Supervised gen_server calls OpenAI chat completions.
