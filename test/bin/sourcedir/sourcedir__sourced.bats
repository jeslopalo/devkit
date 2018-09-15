#!/usr/bin/env bash

load _init_sourced

@test "$(testcase) should success without params" {
    run source_dir
    assert_success
}

@test "$(testcase) should get parent directory of the sourcedir command without params" {
    run source_dir

    assert_output --partial "$DEVKIT_HOME/bin"
}

@test "$(testcase) should fail with unknown path" {
    run source_dir "path/to/unknown"

    assert_failure
    assert_output "error: path/to/unknown: file or directory not found"
}

@test "$(testcase) should get parent directory of a file" {
    run source_dir "$FIXTURE_ROOT/plain.txt"

    assert_output --partial "$FIXTURE_ROOT"
}

@test "$(testcase) should get parent directory of a symlink" {
    run source_dir "$FIXTURE_ROOT/symlink_to_plain.txt"

    assert_output --partial "$FIXTURE_ROOT"
}

@test "$(testcase) should get parent directory of a directory" {
    run source_dir "$FIXTURE_ROOT/directory"

    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a file" {
    run source_dir -1 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory/depth"

    run source_dir -2 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory"

    run source_dir -3 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a symlink" {
    run source_dir -1 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory/depth"

    run source_dir -2 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory"

    run source_dir -3 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a directory" {
    run source_dir -1 "$FIXTURE_ROOT/directory/depth"
    assert_output "$FIXTURE_ROOT/directory"

    run source_dir -2 "$FIXTURE_ROOT/directory/depth"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get / when the requested depth is greater than the path depth" {
    run source_dir -100 "$FIXTURE_ROOT/directory/depth"
    assert_output "/"
}

@test "$(testcase) should get devkit base with --base" {
    run source_dir --base
    assert_output "$DEVKIT_HOME"
}

@test "$(testcase) should ignore the rest of parameters with --base" {
    run source_dir --base "$FIXTURE_ROOT/directory/depth"
    assert_output "$DEVKIT_HOME"
}
