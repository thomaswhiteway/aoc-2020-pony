
use "buffered"

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

    fun dispose() =>
        _handler.eof()

interface LineHandler
    be handle_line(line: String iso)
    be eof()



class PasswordRule
    var _min: U32
    var _max: U32
    var _character: U8

    new create(min: U32, max: U32, character: U8) =>
        _min = min
        _max = max
        _character = character

    fun allows(password: String): Bool => 
        var count: U32 = 0
        for c in password.array().values() do
            if c == _character then
                count = count + 1
            end
        end

        (_min <= count) and (count <= _max)


actor PasswordHandler
    var _total: U32
    let _env: Env

    new create(env: Env) =>
        _total = 0
        _env = env

    fun parse_entry(entry: String): (PasswordRule, String)? =>
        let parts = entry.split_by(": ")
        let rule_parts = parts(0)?.split(" ")
        let range = rule_parts(0)?.split("-")

        (
            PasswordRule(range(0)?.u32()?, 
                         range(1)?.u32()?,
                         rule_parts(1)?(0)?),
            parts(1)?
        )

    be handle_line(line: String iso) =>
        try
            (let rules, let password) = parse_entry(consume line)?
            if rules.allows(password) then
                _total = _total + 1
            end
        end

    be eof() =>
        _env.out.print(_total.string())



actor Main
    new create(env: Env) =>
        let finder = PasswordHandler(env)
        let reader = LineReader(finder)
        env.input(consume reader)
