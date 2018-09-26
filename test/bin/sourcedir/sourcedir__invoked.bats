#!/usr/bin/env bats

load _init

@test "$(testcase) should success without params" {
    run sourcedir
    assert_success
}

@test "$(testcase) should get parent directory of the sourcedir command without params" {
    run sourcedir

    assert_output --partial "$DEVKIT_HOME/bin"
}

@test "$(testcase) should fail with unknown path" {
    run sourcedir "path/to/unknown"

    assert_failure
    assert_output "error: path/to/unknown: file or directory not found"
}

@test "$(testcase) should get parent directory of a file" {
    run sourcedir "$FIXTURE_ROOT/plain.txt"

    assert_output --partial "$FIXTURE_ROOT"
}

@test "$(testcase) should get parent directory of a symlink" {
    run sourcedir "$FIXTURE_ROOT/symlink_to_plain.txt"

    assert_output --partial "$FIXTURE_ROOT"
}

@test "$(testcase) should get parent directory of a directory" {
    run sourcedir "$FIXTURE_ROOT/directory"

    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a file" {
    run sourcedir -1 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory/depth"

    run sourcedir -2 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory"

    run sourcedir -3 "$FIXTURE_ROOT/directory/depth/depth_file.txt"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a symlink" {
    run sourcedir -1 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory/depth"

    run sourcedir -2 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT/directory"

    run sourcedir -3 "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get the nth parent directory of a directory" {
    run sourcedir -1 "$FIXTURE_ROOT/directory/depth"
    assert_output "$FIXTURE_ROOT/directory"

    run sourcedir -2 "$FIXTURE_ROOT/directory/depth"
    assert_output "$FIXTURE_ROOT"
}

@test "$(testcase) should get / when the requested depth is greater than the path depth" {
    run sourcedir -100 "$FIXTURE_ROOT/directory/depth"
    assert_output "/"
}

@test "$(testcase) should get devkit base with --base" {
    run sourcedir --base
    assert_output "$DEVKIT_HOME"
}

@test "$(testcase) should ignore the rest of parameters with --base" {
    run sourcedir --base "$FIXTURE_ROOT/directory/depth"
    assert_output "$DEVKIT_HOME"
}
