-- Example of function declarations, conditional expressions and
-- some simple arithmetic
fix f = f (fix f)
fac f n = if n == 0 then 1 else n * f (n - 1)

-- To call this in Elm, try `fix fac 3`. Why does it result in a runtime error?

-- Some example datatype declarations
type Fruit = Apple | Orange | Banana
type List a = Empty | Cons a (List a)

-- Surprise! You can have function arrows too!
type Mu a = Mu (Mu a -> a)
