# gke-private-deploy

This build step invokes `kubectl` commands in [Google Cloud Build](https://cloud.google.com/cloud-build) via a bastion VM.


## Building this Builder

Before using this builder in a Cloud Build config, it must be built and pushed to the registry in your 
project. Run the following command in this directory:
```
gcloud builds submit .
```

## Note on gke-deploy

The official google-builder repos have a gke-deploy image which exposes `prepare`, `apply` and `run` commands.
This image was initially developed as a wrapper to `gke-deploy`; however, it was not possible to proxy the 
gcloud sdk calls which happened inside `gke-deploy` (the metadata server rejects proxied requests, see:
[https://cloud.google.com/compute/docs/storing-retrieving-metadata#x-forwarded-for_header](https://cloud.google.com/compute/docs/storing-retrieving-metadata#x-forwarded-for_header))

This unfortunately means we lose all the gke-deploy functionality.
