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
    let _seen : Array[U32]
    let _candidates: Map[U32, (U32, U32)]

    new create(env: Env, target: U32) =>
        _env = env
        _target = target
        _candidates = Map[U32, (U32, U32)]
        _seen = Array[U32]

    be handle_entry(entry: U32) =>
        let needed: U32 = _target - entry
        try 
            (let x: U32, let y: U32) = _candidates(needed)?
            let result = entry * x * y
            _env.out.print(result.string())
        end

        for other in _seen.values() do
            _candidates.insert(entry + other, (entry, other))
        end

        _seen.push(entry)

actor Main
    new create(env: Env) =>
        let finder = MatchFinder(env, 2020)
        let parser = EntryParser(finder)
        let reader = LineReader(parser)
        env.input(consume reader)


