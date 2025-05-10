// A generated module for SampleNodejs functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
	"dagger/sample-nodejs/internal/dagger"
	"fmt"
	"math"
	"math/rand/v2"
)

type SampleNodejs struct{}

// Returns a container that echoes whatever string argument is provided
func (m *SampleNodejs) ContainerEcho(stringArg string) *dagger.Container {
	return dag.Container().From("alpine:latest").WithExec([]string{"echo", stringArg})
}

// Returns lines that match a pattern in the files of the provided Directory
func (m *SampleNodejs) GrepDir(ctx context.Context, directoryArg *dagger.Directory, pattern string) (string, error) {
	return dag.Container().
		From("alpine:latest").
		WithMountedDirectory("/mnt", directoryArg).
		WithWorkdir("/mnt").
		WithExec([]string{"grep", "-R", pattern, "."}).
		Stdout(ctx)
}

// Build and publish image from existing Dockerfile
func (m *SampleNodejs) Build(
	ctx context.Context,
	// location of directory containing Dockerfile
	src *dagger.Directory,
) (string, error) {
	ref, err := src.
		DockerBuild(). // build from Dockerfile
		Publish(ctx, fmt.Sprintf("ttl.sh/hello-dagger-%.0f", math.Floor(rand.Float64()*10000000)))

	if err != nil {
		return "", err
	}

	return ref, nil
}
