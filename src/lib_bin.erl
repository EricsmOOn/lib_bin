%%----------------------------------------------------
%% @doc
%% 二进制操作
%% @author Eric Wong
%% @end
%% Created : 2021-09-08 11:30 Wednesday
%%----------------------------------------------------
-module(lib_bin).
-export([
        finds/2
        ,write/2
        ,read/1
        ,replace/3
        ,replace_all/3
    ]).

%%----------------------------------------------------
%% 外部接口
%%----------------------------------------------------
%% @doc 文本查找
-spec finds(Text::bitstring(), StartBins::[bitstring()]) -> [{StartPos::integer(), Len::integer()}].
finds(Text, StartBins) ->
    case binary:matches(Text, StartBins) of
        Result = [_ | _] ->
            Result;
        _ ->
            []
    end.

%% @doc 二进制写入
-spec write(File::string(), FBin::bitstring()) -> ok.
write(File, FBin) ->
    {ok, S} = file:open(File, [raw, write, binary]),
    ok = file:pwrite(S, 0, FBin),
    ok = file:close(S).

%% @doc 二进制读入
-spec read(File::string()) -> FBin::bitstring().
read(File) ->
    case file:read_file(File) of
        {ok, FBin} ->
            FBin
    end.

%% @doc 二进制单次替换
-spec replace(FBin::bitstring(), SrcBin::bitstring(), DestBin::bitstring()) -> NFBin::bitstring().
replace(FBin, SrcBin, DestBin) ->
    case find_start(FBin, SrcBin) of
        [Start | _] ->
            Len = erlang:size(SrcBin),
            <<FBinPre:Start/binary, _:Len/binary, FBinSuf/binary>> = FBin,
            <<FBinPre/binary, DestBin/binary, FBinSuf/binary>>;
        _ ->
            FBin
    end.

%% @doc 二进制全替换
-spec replace_all(FBin::bitstring(), SrcBin::bitstring(), DestBin::bitstring()) -> NFBin::bitstring().
replace_all(FBin, SrcBin, DestBin) ->
    case replace(FBin, SrcBin, DestBin) of
        FBin -> FBin;
        NFBin -> replace_all(NFBin, SrcBin, DestBin)
    end.

%%----------------------------------------------------
%% 内部私有
%%----------------------------------------------------
find_start(FBin, StartBin) ->
    case binary:matches(FBin, [StartBin]) of
        Result = [_ | _] ->
            [Start || {Start, _} <- Result];
        _ ->
            []
    end.

