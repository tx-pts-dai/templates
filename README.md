# Templates

Holds templates that can be customized through your favourite template engine (e.g. [Jinja](https://palletsprojects.com/projects/jinja/)).

For an application you can pick your favourite [base](./bases/), and then add any addons you like.

These are the rules:

1. Only 1 base must be used.
1. 0 to infinite addons can be added (afterwards).

That's how you identify if your template is a `base` or an `addon`.

## Cookiecutter

This repository maintains multiple [cookiecutter](https://www.cookiecutter.io/) templates.

To configure a cookie cutter template, create a `cookiecutter.json` file in the root of the template directory and add your folder with the templated files. Folder names can also be templated, so you can use the `@{{ cookiecutter.project_slug }}` variable in the folder name.

Example:

```text
mkdocs
├── @{{ cookiecutter.project_slug }}
│   ├── docs
│   │   ├── README.md
│   │   ├── faq.md
│   │   ├── getting-started.md
│   │   ├── index.md
│   │   └── requirements.txt
│   └── mkdocs.yaml
└── cookiecutter.json
```

All the variables in the `cookiecutter.json` file are required to be used at least once in the template files otherwise an error will be produced.
