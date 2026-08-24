-module(mini_ai_server).
-behaviour(gen_server).

-export([start_link/0, ask/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

ask(Prompt) ->
    gen_server:call(?MODULE, {ask, Prompt}, 30000).

init([]) ->
    inets:start(),
    ssl:start(),
    {ok, #{}}.

handle_call({ask, Prompt}, _From, State) ->
    Key = os:getenv("OPENAI_API_KEY"),
    case Key of
        false -> {reply, {error, no_api_key}, State};
        _ ->
            Body = jsx:encode(#{model => <<"gpt-4o-mini">>,
                                messages => [#{role => <<"user">>, content => list_to_binary(Prompt)}]}),
            Headers = [{"Authorization", "Bearer " ++ Key},
                       {"Content-Type", "application/json"}],
            Request = {"https://api.openai.com/v1/chat/completions", Headers, "application/json", Body},
            case httpc:request(post, Request, [{timeout, 20000}], []) of
                {ok, {{_, 200, _}, _, RespBody}} ->
                    {reply, {ok, RespBody}, State};
                {ok, {{_, Code, _}, _, RespBody}} ->
                    {reply, {error, {Code, RespBody}}, State};
                {error, Reason} ->
                    {reply, {error, Reason}, State}
            end
    end;
handle_call(_Req, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_Old, State, _Extra) -> {ok, State}.
