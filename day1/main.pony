use "buffered"
use "collections"

class LineReader is InputNotify
    let _handler: LineHandler tag
    let _buffer: Reader

    new iso create(handler: LineHandler tag) => 
        _handler = handler
        _buffer = Reader

    fun ref apply(data: Array[U8] iso) =>
        _buffer.append(consume data)

        try 
            while true do
                let line = _buffer.line()?
                _handler.handle_line(consume line)
            end
        end

interface LineHandler
    be handle_line(line: String iso)

actor EntryParser
    let _handler: EntryHandler tag

    new create(handler: EntryHandler tag) =>
        _handler = handler

    be handle_line(line: String iso) =>
        try
            let value = line.u32()?
            _handler.handle_entry(value)
        end

interface EntryHandler
    be handle_entry(entry: U32)

actor MatchFinder
    let _env: Env
    let _target: U32
    let _seen: Set[U32]

    new create(env: Env, target: U32) =>
        _env = env
        _target = target
        _seen = Set[U32]()

    be handle_entry(entry: U32) =>
        let needed: U32 = _target - entry
        if _seen.contains(needed) then
            let result = entry * needed
            _env.out.print(result.string())
        end

        _seen.set(entry)

actor Main
    new create(env: Env) =>
        let finder = MatchFinder(env, 2020)
        let parser = EntryParser(finder)
        let reader = LineReader(parser)
        env.input(consume reader)


