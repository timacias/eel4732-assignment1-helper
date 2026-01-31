# eel4732-assignment1-helper
A helper script for assignment 1 of Advanced Systems Programming (EEL4732)

This script automates the process of building and testing your assignment, simply specify the location of your test cases and source files.

## Usage
Examples:

Build all items in source_files and run all assignment 1 tests: `./test.sh build all && ./test.sh all`

Test the individual transformers w/ verbose output: `./test.sh transformers -v`

Run tests from preliminary assignment 1: `./test.sh prelim`

Specify a directory to run tests from: `./test.sh all -t "tests/case"`

Only build transformerI.c and magic_transformer.c `./test.sh -f transformerI.c magic_transformer.c`
```
Usage: ./test.sh [options]
        b, build [all]                  Rebuild magic_transformer, g++ will be called directly
                                         unless a makefile is present in source_dir.
                                         If all is passed, rebuild all source files
        c, clean                        Remove all transformer executables
        t, transformers [-v]            Test transformers 1-3
        m, magic [-v]                   Test magic_transformer
        a, all [-v]                     Run all tests (except prelim)
        p, prelim [-v]                  Run preliminary test cases
        -t, --test [PATH]               Specify a path prefix where your test cases are located
        -s, --source [PATH]             Specify a path where your source is located
        -f, --file [LIST]               Specify a list of source files to compile
        -h, --help                      Print this message
        -v, --verbose                   Enable verbose output for options that support it
        --version                       Print the version
```

## Configuration
The 3rd - 5th columns indicate where each variable can be modified
| Variable Name | Default Value | Top of Script | Environment Variables | Cmd Line Options |
| - | - | - | - | - |
| test_path_prefix | `"assn1_testcases/testcases/case"` | ✅ | ✅ | ✅ |
| prelim_test_path_prefix | `"prelim_assn1_testcases/prelim_assn1_testcases/Transformer"` | ✅ | ✅ | ❌ |
| source_dir | `"src"` | ✅ | ✅ | ✅ |
| source_files | `("magic_transformer.cpp" "transformer1.cpp" "transformer2.cpp" "transformer3.cpp")` | ✅ | ❌ | ✅ |
| num_transformer_tests | `60` | ✅ | ✅ | ❌ |
| num_magic_tests | `20` | ✅ | ✅ | ❌ |
| num_prelim_tests | `3` | ✅ | ✅ | ❌ |
| CC | `g++` | ✅ | ✅ | ❌ |

## License
This script is released under the GNU General Public License, version 3 or later.
