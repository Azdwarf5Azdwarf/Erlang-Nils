-module(mini_ai_server_tests).
-include_lib("eunit/include/eunit.hrl").

ask_without_key_test() ->
    true = os:unsetenv("OPENAI_API_KEY"),
    {ok, _} = mini_ai_server:start_link(),
    ?assertEqual({error, no_api_key}, mini_ai_server:ask("hi")).
