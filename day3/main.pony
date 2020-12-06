
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

actor MapBuilder
    var _buffer: Array[String iso] iso
    let _handler: MapHandler tag

    new create(handler: MapHandler tag) =>
        _buffer = recover iso Array[String iso] end
        _handler = handler

    be handle_line(line: String iso) =>
        _buffer.push(consume line)

    be eof() =>
        _handler.handle_map(_buffer = recover iso Array[String iso] end)


interface MapHandler
    be handle_map(map: Array[String iso] iso) 

actor Main
    let _env: Env

    new create(env: Env) =>
        _env = env

        let builder = MapBuilder(this)
        let reader = LineReader(builder)
        env.input(consume reader)

    fun count_trees(map: Array[String iso] val, dx: USize, dy: USize): USize =>
        var x: USize = 0
        var y: USize = 0
        var trees: USize = 0

        while y < map.size() do
            try
                let row = map(y)?
                if row(x % row.size())? == '#' then
                    trees = trees + 1
                end
            end

            x = x + dx
            y = y + dy
        end

        trees

    be handle_map(map: Array[String iso] iso) =>
        let trees = count_trees(consume map, 3, 1)
        _env.out.print(trees.string())


    