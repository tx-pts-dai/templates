# Documentation

This directory contains documentation that is used as content to generate Github Pages deployment with MkDocs.

## Local Development

To serve the contributing guide locally, [`mkdocs`](https://www.mkdocs.org/user-guide/installation/) and the [`mkdocs-material`](https://github.com/squidfunk/mkdocs-material#quick-start) extension must be installed. Both require Python and `pip`.

```console
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r docs/requirements.txt
```

Once installed, the documentation can be served from the root directory:

```console
mkdocs serve
```
