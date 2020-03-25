#### Build singularity images

```bash
singularity remote login # paste API key from cloud.sylabs.com

# For every recipe
singularity build --remote NAME_OF_IMAGE RECIPE
```

