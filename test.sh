#!/usr/bin/env bash

# Change these as needed to accomodate your directory structure
: "${test_path_prefix:="assn1_testcases/testcases/case"}"
: "${prelim_test_path_prefix:="prelim_assn1_testcases/prelim_assn1_testcases/Transformer"}"
: "${source_dir:="src"}"

# Add the names of your source files here
source_files=("magic_transformer.cpp" "transformer1.cpp" "transformer2.cpp" "transformer3.cpp")
#: "${source_files:=("magic_transformer.cpp" "transformer1.cpp" "transformer2.cpp" "transformer3.cpp")}"

# If you add or remove tests, modify these
: "${num_transformer_tests:=60}"
: "${num_magic_tests=20}"
: "${num_prelim_tests=3}"

# If you wish to use a different compiler, modify this
: "${CC="g++"}"

: '
Copyright © 2026 Timothy Macias

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
'

###############################################################

failed_cases=()

print_help() {
	cat <<EOF
Helper script for EEL4732 assignment 1

This script expects the latest provided test cases and the following source files:
 ${source_files[@]}

Please change the test_path_prefix, source_dir, and source_files variables at the
 top of the script as needed to accommodate your project. This can also be done by
 passing options or environment variables.
 For example, if your test case folders (e.g., case0, case1, etc.) are located at
 "/path/to/tests/". Set test_path_prefix to "/path/to/tests/case". For source_dir,
 simply set it to the directory where your source code is located.

Usage: ./test.sh [options]
	b, build [all]			Rebuild magic_transformer, $CC will be called directly
					 unless a makefile is present in source_dir.
					 If all is passed, rebuild all source files
	c, clean			Remove all transformer executables
	t, transformers [-v]		Test transformers 1-3
	m, magic [-v]			Test magic_transformer
	a, all [-v]			Run all tests (except prelim)
	p, prelim [-v]			Run preliminary test cases
	-t, --test [PATH]		Specify a path prefix where your test cases are located
	-s, --source [PATH]		Specify a path where your source is located
	-f, --file [LIST]		Specify a list of source files to compile
					 (e.g., transformerI.c)
	-h, --help			Print this message
	-v, --verbose			Enable verbose output for options that support it
	--version			Print the version

The following variables can be set via the user's environment:
 variable_name 			: current_value
 ----------------------------------------------
 test_path_prefix		: $test_path_prefix
 prelim_test_path_prefix	: $prelim_test_path_prefix
 source_dir			: $source_dir
 num_transformer_tests		: $num_transformer_tests
 num_magic_tests		: $num_magic_tests
 num_prelim_tests		: $num_prelim_tests
 CC				: $CC
EOF

	exit 0
}

parse_source_files() {
	# Clear the default list of source files
	source_files=()

	# Filter all args after --file for C/C++ source files
	for elem in "$@"; do
		[[ $elem == *.c* ]] && source_files+=("$elem");
	done

	return ${#source_files[@]}
}

# Use `./test.sh build all` to rebuild all source files
# `./test.sh build` builds only magic_transformer
build() {
	if [ "$1" = "all" ]; then
		for file in "${source_files[@]}"; do
			$CC -o "${file%.*}" "$source_dir/$file"
		done
	else
		$CC -o magic_transformer "$source_dir/magic_transformer.c"*
	fi

	exit 0
}

# $1 is $i
run_magic() {
	output=$( bash "$test_path_prefix$1/run_magic_transformer.sh" \
		< "$test_path_prefix$i/input.txt" \
		1> >(sort | diff - <(sort "$test_path_prefix$i/stdout.txt")) \
		2> >(sort | diff - <(sort "$test_path_prefix$i/stderr.txt")) )
	wait

	if [ -n "$output" ]; then
		failed_cases+=("magic_transformer - Case $1")

		if [ "$verbose" = true ]; then
			echo -e "\nFAILED: ${failed_cases[-1]}\n$output\n"
		fi
	fi
}

# $1 is $i
# $2 is the transformer to run
# $3 is the input file
# $4 is the stdout file
# $5 is the stderr file
run_transformer() {
	output=$( ./transformer"$2" < "$test_path_prefix$1/$3.txt" \
		1> >(sort | diff - <(sort "$test_path_prefix$1/$4.txt")) \
		2> >(sort | diff - <(sort "$test_path_prefix$1/$5.txt")) )
	wait

	if [ -n "$output" ]; then
		failed_cases+=("Transformer $2 - Case $1")

		if [ "$verbose" = true ]; then
			echo -e "\nFAILED: ${failed_cases[-1]}\n$output"
		fi
	fi

}

# $1 is the transformer to run
# $2 is the input file
# $3 is the stdout file
# $4 is the stderr file
run_prelim() {
	output=$( ./transformer"$1" < "$prelim_test_path_prefix$1/$2.txt" \
		1> >(sort | diff - <(sort "$prelim_test_path_prefix$1/$3.txt")) \
		2> >(sort | diff - <(sort "$prelim_test_path_prefix$1/$4.txt")) )
	wait

	if [ -n "$output" ]; then
		failed_cases+=("Transformer $1")

		if [ "$verbose" = true ]; then
			echo -e "\nFAILED: ${failed_cases[-1]}\n$output\n"
		fi
	fi

}

# $1 is the number of total cases ran
print_results() {
	echo -ne "All tests completed!\n\n"

	# Let the user know which cases failed
	if [ -z "$failed_cases" ]; then
		echo "All tests passed!"
	else
		echo -e "Passed [$(($1-${#failed_cases[@]}))/$1] cases\n\nFAILED:"
		printf '%s\n' "${failed_cases[@]}"
	fi

	exit 0
}

anna_setup() {
	source_dir="."
	source_files=("magic_transformer.cpp" "transformerI.cpp" "transformerII.cpp" "transformerIII.cpp")
	echo "c: ❤️"
}

# Print the help menu if no args have been passed
if [ $# -eq 0 ]; then
	print_help
fi

# Option handling
while [ $# -gt 0 ]; do
	case "$1" in
		b|build) build=true && build_arg="$2"
			if [ "$build_arg" = "all" ]; then
				shift
			fi
			;;
		c|clean) clean=true
			;;
		t|transformers) test_transformers=true
			;;
		m|magic) test_magic=true
			;;
		a|all) test_magic=true && test_transformers=true
			;;
		p|prelim) test_prelim=true
			;;
		-t|--test) test_path_prefix="$2"
			shift
			;;
		-s|--source) source_dir="$2"
			shift
			;;
		-f|--file) build=true && build_arg="all" && parse_source_files "$@"
			shift $?
			;;
		-h|--help) print_help
			;;
		-v|--verbose) verbose=true
			;;
		--version) echo "2026.01.31" && exit 0
			;;
		--anna) anna_setup
			;;
		*) echo -e "Invalid option: $1\nTry running $0 --help" && exit 1
			;;
	esac
	shift
done

# Driver code
if [ "$build" = true ]; then

	# Check if a makefile exists
	if [ -f "$source_dir/Makefile" ] || [ -f "$source_dir/makefile" ]; then
		pushd "$source_dir" || exit
		make
		exit 0
	else	# Otherwise build normally
		build "$build_arg"
	fi

elif [ "$clean" = true ]; then

	# Remove all compiled files
	for file in "${source_files[@]}"; do
		rm "${file%.*}"
	done

	exit 0

elif [ "$test_transformers" = true ] || [ "$test_magic" = true ]; then

	echo -e "Running tests..."

	num_tests_ran=0

	for i in {1..19}; do
		echo -ne "Running case $i...\r"

		if [ "$test_magic" = true ]; then
			run_magic "$i"
		fi
		if [ "$test_transformers" = true ]; then
			run_transformer "$i" "1" "input" "performance" "rating"
			run_transformer "$i" "2" "performance" "agent_performance" "state_performance"
			run_transformer "$i" "3" "rating" "agent_rating" "state_rating"
		fi
	done

	if [ "$test_magic" = true ]; then
		num_tests_ran=$((num_tests_ran+num_magic_tests))
	fi
	if [ "$test_transformers" = true ]; then
		num_tests_ran=$((num_tests_ran+num_transformer_tests))
	fi

	print_results "$num_tests_ran"

elif [ "$test_prelim" = true ]; then

	echo -ne "Testing Transformer 1...\r"
	run_prelim "1" "input" "performance" "rating"
	wait

	echo -ne "Testing Transformer 2...\r"
	run_prelim "2" "input" "agent_performance" "state_performance"
	wait

	echo -ne "Testing Transformer 3...\r"
	run_prelim "3" "input" "agent_rating" "state_rating"
	wait

	echo -ne "                        \r"
	print_results "$num_prelim_tests"
fi
