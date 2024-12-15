vim9script

# Function without return type
def FunctionWithoutReturn(arg: string)
  echo arg
enddef

# Function with missing argument type
def FunctionMissingArgType(arg, another: string): void
  echo arg
enddef

# Function with no argument types
def FunctionNoArgTypes(arg1, arg2): void
  echo arg1
  echo arg2
enddef

# Function with missing both argument and return types
def FunctionNoTypes(arg)
  echo arg
enddef

# Function with a correctly ignored argument but missing type on another
def FunctionWithIgnoredArg(_, arg): void
  echo arg
enddef

# Function with invalid variable arguments
def FunctionInvalidVarArgs(...args): void
  for arg in args
    echo arg
  endfor
enddef

# Function with correct usage (to ensure it doesn't flag correctly written code)
def FunctionCorrect(arg: string, another: number): void
  echo arg . another
enddef

