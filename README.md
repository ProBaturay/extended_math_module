# Extended Math Module
An alternative module with new mathematical equations, constants, etc. to the original math library provided by Roblox. The original library permits you to access functions and numbers directly, but the reason this successor exists is that it gets complicated by adding new methods and constants in math library. Therefore, some mathematical terms may interchange meanings from one another. This is where the library is overhauled, also with the typechecking and parallel executing feature!

### Examples for overwriting into the math library with this module

#### Different type of calls

```lua
local abs : number = math.abs(-4)
local pi : number = math.pi

print(abs, pi)
```

They both return a number overall, but the direct referring prevents it from being known whether it is a function or a number. Since other constants such as Euler's constant comprise the values with the others, it will be more difficult to interpret them all. Below is another example.

#### Non-existent methods and executing in parallel

```lua
local function factorialize(a : number) : number
    local factorialized : number = 1
    
    repeat
        factorialized *= a
        a -= 1
    until a == 0
    
    return factorialized :: number
end
```

The function above calculates the [factorial](https://en.wikipedia.org/wiki/Factorial) of the number passed as a parameter. But this function doesn't exist in the math library. Let's continue discussing about this method.

```lua
task.desynchronize()
--Some stuff
task.synchronize()
```

There are two types of processing the engine for which the game runs will schedule its business: Serial and parallel. As can be inferred from the words themselves, the engine executes codes in the order in the serial mode, while in the parallel mode, safe methods called within the execution environment are processed separately and instantly. I've instilled this feature in the codes!

#### String expressions of algebraic equations

Moreover, this module supports algebraic equations! You can derive equations such as binomial expressions. Unfortunately, there is currently no API to abbreviate expansions. It requires high programming skills and takes too much time. An example of expanding a binomial expression:

```lua
local function expand_binomial(firstTerm : string, secondTerm : string, exponent : number) : string -- Equations having more than second terms will be considered as a tuple 
    local expression : string = ""                                                                  -- The tuple parameter is wrong because this function is designed for only those that have two terms
    local firstCoefficient : string = string.match(firstTerm, "%d+")
    local secondCoefficient : string = string.match(secondTerm, "%d+")
    
    -- I am not putting all the code because it is long.
    
    return expression :: string
end
```

### Overall

As this module gets more impressions, it will continue to improve itself, and discover new methods. Better coding, better style.

## Happy Programming!
