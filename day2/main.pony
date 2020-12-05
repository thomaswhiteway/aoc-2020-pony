
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
    var _first: USize
    var _second: USize
    var _character: U8

    new create(first: USize, second: USize, character: U8) =>
        _first = first - 1
        _second = second - 1
        _character = character

    fun allows(password: String): Bool => 
        try
            (password(_first)? == _character) xor (password(_second)? == _character)
        else
            false
        end

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
            PasswordRule(range(0)?.usize()?, 
                         range(1)?.usize()?,
                         rule_parts(1)?(0)?),
            parts(1)?
        )

    be handle_line(line: String iso) =>
        try
            (let rules, let password) = parse_entry(line.clone())?
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
