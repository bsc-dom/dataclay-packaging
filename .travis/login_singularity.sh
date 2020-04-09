#!/bin/bash
# Login singularity
openssl aes-256-cbc \
	-K $encrypted_0680b2354a01_key \
	-iv $encrypted_0680b2354a01_iv \
	-in .travis/singularity_cloud_token.enc \
	-out .travis/singularity_cloud_token -d
	
singularity remote login < .travis/singularity_cloud_token
