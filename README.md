# Vanilla OS Core Image
Containerfile for building a vanilla OS Core image.

> This image is not intended to be used directly. It is used as a base image for other images.
> Like the Vanilla OS Desktop or the KDE Edition.

## Build

You need the [Vib](https://github.com/vanilla-os/Vib) tool to generate the Containerfile.

```bash
vib build recipe.yml
podman image build -t vanillaos/core .
```

