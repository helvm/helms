

# Dupe
**Dupe** (formerly *Reverse Scheme*)

Scheme -> UnScheme -> Dupe -> UnLambda+ -> UnLambda

* PreScheme - Scheme compiled by SICP
* UnScheme - Scheme but every special formulas are macros. Macro are created from lambdas
* Dupe - all `define lambda` defined in special dictionary
* UnLambda+ - all lambdas are inlined, still use primitives
* Dupe does not have lambdas, only deltas. Because deltas change the stack

## Syntax
* `end` - `nil`, end of list, empty list
* list - `end` c : b : a :
* if - if-false condition if-true `if`
* define function - 
* call function - list-of-expression name-of-function
* `where` - better wersion of `let`, expresion-body list-of-expresion-and-name `where` 
* `where*` - better wersion of `let*`
* `do` - better `begin`
* `begin` and `define` pair is replaced by `where*` in compilation
* function - expresion `end` `end`

## Match

If = match
```
match {
  case true => a
  case false => b 
}
if {
  then a
  else b
}
```
pipe = match
```
match {
  case a => a + 1
}
pipe {
  a => a + 1
}
|> {
 a => a + 1
} 
```
