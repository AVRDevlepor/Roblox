-- poopy lua interpreter i made that can only run print and incorrectly return just for a proof-of-concept
local function pack(...)
    return select('#', ...), {...}
end

local function Interpret(Chunk, Env)
    local PC, Stack, Top = 0, {}, -1

    while true do
        PC = PC + 1
        local Instr = Chunk.Instructions[PC]
        if Instr.op == 1 then -- OP_LOADK 
            Stack[Instr.a] = Chunk.Constants[Instr.b]
        elseif Instr.op == 7 then -- OP_GETGLOBAL
            Stack[Instr.a] = Env[Chunk.Constants[Instr.b]]
        elseif Instr.op == 28 then -- OP_CALL
            local NumParams;
            if Instr.b == 0 then
                NumParams = Top - Instr.a
            else
                NumParams = Instr.b - 1
            end

            local NumRet, RetArgs = pack(Stack[Instr.a](unpack(Stack, Instr.a + 1, Instr.a + NumParams)))
            if Instr.C == 0 then
                Top = Instr.a + NumRet - 1
            else
                NumRet = Instr.c - 1
            end

            local j = 0
            for i = Instr.a, NumRet do
                j = j + 1
                Stack[i] = RetArgs[j]
            end
        elseif Instr.op == 30 then -- OP_RETURN
        	break; -- too lazy to implement this correctly
        end
    end
end

Interpret({
    Instructions = {
        { op = 7,  a = 0, b = 1 },        -- GETGLOBAL 0 1
        { op = 1,  a = 1, b = 2 },        -- LOADK     1 2
        { op = 28, a = 0, b = 2, c = 1 }, -- CALL      0 2 1
        { op = 30, } -- too lazy to implement RETURN fully.
    },
    Constants = {
        "warn", "Hello, world!"
    }
}, getfenv())
