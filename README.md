- [Overview](#org50cf569)
- [Installation](#orga9b2f1a)
  - [Install the ox-gfm Emacs package](#org71ddbc2)
  - [Install the gem](#orgb14a7d2)
  - [Update Your `Rakefile`](#orgadadcb7)
- [Usage](#orge9c6a9b)
  - [Add proper `#+PROPERTY` headers in `README.org`: \`rake docs:headers\`](#orgfb0b535)
  - [Run the Code Blocks in README.org: \`rake docs:tangle\`](#orgbdc73bd)
  - [Ensure that a Badge is Present in `README.md`: \`rake docs:badge\`](#org11b5e65)
  - [Export `README.org` to `README.md`: \`rake docs:export\`](#orga42c221)
  - [Generate Yard Documents: \`rake docs:yard\`](#org4771f80)
  - [Generate an Overview Comment for the Main gem File: \`rake docs:overview\`](#orge03fb80)
- [Confguration](#orgfd976a7)
- [Development](#orge2657b7)
- [Contributing](#orga6c8dfa)
- [License](#org56063ac)

[![CI](https://github.com/ddoherty03/gem_docs/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/ddoherty03/gem_docs/actions/workflows/main.yml)


<a id="org50cf569"></a>

# Overview

One of the more onerous tasks when writing a `gem` or other `github` project is maintaining the documentation, and keeping it consistent and up-to-date. One of the better options for writing the `README` file that gets displayed by `github` as the main documentation is to write the file in `org-mode`, `README.org` the export it to markdown `README.md` for display by `github`.

Doing so gives you access to `org-mode`'s code blocks for writing example code to demonstrate the `gem` or other documents being presented. If you do so, `github` will render your `README.org` file in `HTML` and give you a credible result. However, `github` cannot handle some `org-mode` features, and in particular, it will not render \`~#+RESULTS~\` blocks showing the results of code block execution unless you wrap the results in something like a \`#+begin\_example\` block and manually delete the \`#+RESULTS\` markers. Exporting to markdown eliminates that hassle.

This gem contains `rake` tasks to facilitate the production of documentation in other gems.

It provides tasks for:

-   ensuring that proper code block setup is included in `README.org` to facilitate running `ruby` code blocks in a session using the current version of the library,
-   running the code block examples in a `README.org` by invoking `emacsclient`,
-   exporting `README.org` to Git-flavored markdown in `README.md`
-   ensuring a workflow or ci badge is present in the `README.md`
-   generating yard documents for your repo, and
-   copying the introductory contents of the README as a leading comment in your main gem library file so it gets picked up as an overview for `ri` and `yri`


<a id="orga9b2f1a"></a>

# Installation


<a id="org71ddbc2"></a>

## Install the ox-gfm Emacs package

The export of `README.org` to `README.md` requires the `ox-gfm` package to be installed in Emacs. If you use `use-package`, this will suffice:

```emacs-lisp
(use-package ox-gfm)
```


<a id="orgb14a7d2"></a>

## Install the gem

Install the gem and add to the application's `Gemfile` by executing:

```sh
bundle add gem_docs
```

If bundler is not being used to manage dependencies, install the gem by executing:

```sh
gem install gem_docs
```


<a id="orgadadcb7"></a>

## Update Your `Rakefile`

To use this gem place the following lines in your gem's `Rakefile`:

```ruby
require "gem_docs"
GemDocs.install
```


<a id="orge9c6a9b"></a>

# Usage


<a id="orgfb0b535"></a>

## Add proper `#+PROPERTY` headers in `README.org`: \`rake docs:headers\`

Getting emacs code blocks to render well in your `README.org` takes proper configuration of the code block headers in Emacs.

```ruby
rake docs:headers
```

By default, the `gem_docs` `rake docs:headers` task will add the following headers to the top of your `README.org` file. It does nothing if any ruby header args are already present, so remove them if you want these installed.

```
#+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
#+PROPERTY: header-args:ruby+ :wrap example :session gem_docs_session
#+PROPERTY: header-args:ruby+ :prologue "$:.unshift('./lib') unless $:.first == './lib'; require '%n'"
#+PROPERTY: header-args:sh :exports code :eval no
#+PROPERTY: header-args:bash :exports code :eval no
```

Here's what the ruby headers buy you:

-   **`:results value`:** the value of the last expression in the block is rendered as the results of code execution. If you want the output instead for a particular block, just add the block argument `:results output` to the code block.
-   **`:colnames no`:** prevents org from processing the column headers in tables it renders. It is better for you to control column headers, and this setting allows this.
-   **`:hlines yes`:** prevents org from stripping hlines from tables, which also allows you to control the insertion of hlines in tables.
-   **`:exports both`:** causes both your code and the results of evaluation to be exported to the `README.md`. Your example blocks should demonstrate the use of the gem, and the reader will want to see both the code and its results.
-   **`:dir "./"`:** causes each code block to execute with your gem's root directory as its current directory.
-   **`:wrap example`:** this wraps the result of code block evaluation in \`~#+begin\_example~\` / \`~#+end\_example~\` so that the results are displayed literally.
-   **`:session gem_docs_session`:** causes the code blocks to execute in a continuous session, so that variables set up in one code block are accessible in later code blocks. Without this, you would have to build the code environment anew with each code block which obscures the readability of your `README`. The session name is set to '<gem\_name>\_session' automatically, where <gem\_name> is the name of your gem.
-   `:prologue "$:.unshift('./lib') unless $:.first == './lib'; require 'gem_name'"` :: this prologue gets executed before each code block execution and ensures that the version of the gem library is you current development version; otherwise, your code blocks could be running a version from a prior installation of the gem. The 'gem\_name' in the require is set to the name of your gem automatically.

The `docs:headers` task also turns off evaluation of shell code blocks since these will often be such things as demonstrating the shell commands to install the gem, etc. Of course, you can override this for particular code blocks.

Those headers are in fact what I am using in this `README`, and here is how they work:

```ruby
result = []
result << ['N', 'exp(N)']
result << nil
0.upto(10) do |n|
  result << [n/3.0, Math.exp(n/3.0)]
end
result
```

```
|                  N |             exp(N) |
|--------------------+--------------------|
|                0.0 |                1.0 |
| 0.3333333333333333 | 1.3956124250860895 |
| 0.6666666666666666 | 1.9477340410546757 |
|                1.0 |  2.718281828459045 |
| 1.3333333333333333 | 3.7936678946831774 |
| 1.6666666666666667 |   5.29449005047003 |
|                2.0 |   7.38905609893065 |
| 2.3333333333333335 | 10.312258501325767 |
| 2.6666666666666665 | 14.391916095149892 |
|                3.0 | 20.085536923187668 |
| 3.3333333333333335 |  28.03162489452614 |
```

I built the table in the output by returning an array of arrays, which org-mode renders as a table in the output. Notice that I added an hline to the output by simply adding `nil` to the outer array where I wanted the hline to occur.

Apart from all the convenient markup that `org-mode` allows, the ability to easily demonstrate your gem's code in this way is the real killer feature of writing your `README` in `org-mode` then exporting to markdown.


<a id="orgbdc73bd"></a>

## Run the Code Blocks in README.org: \`rake docs:tangle\`

You can invoke `emacsclient` to run all the example code blocks in your `README.org` that are set for evaluation:

Note that the `tangle` task relies on `emacsclient` to evaluate the code blocks in `README.org`, so your Emacs `init` files should start [the Emacs server](info:emacs#Emacs Server) in order to work properly.

I use the following snippet in my Emacs init file:

```emacs-lisp
(require 'server)
(unless (server-running-p)
  (message "Starting Emacs server")
  (server-start))
```

Then, you can evaluate all the code blocks in your `README.org` like this:

```ruby
rake docs:tangle
```


<a id="org11b5e65"></a>

## Ensure that a Badge is Present in `README.md`: \`rake docs:badge\`

It is reassuring to consumers of your gem that your gem passes its workflow tests on github. This task checks to see if a "badge" indicating success or failure is present and, if not, inserts one at the top of the `README.org` such that it will get exported to `README.md` when `rake docs:export` is run.

If you want to place the badge somewhere else in you `README.org`, place the special comment `#badge` where you want the badge located and the task will place it there.

If there is already a badge present, the task will not modify the `README.org` file.


<a id="orga42c221"></a>

## Export `README.org` to `README.md`: \`rake docs:export\`

You can write the `README` in Emacs org-mode, using all its features including the execution of code blocks, and then export to git-flavored markdown.

If your repo contains both `README.org` and `README.md`, github (and gitlab) will render the markdown version.

Github renders markdown better than it renders org files, so this helps with the readability of the `README` on github. For example, if you write the `README` in org mode without exporting to markdown, `github` will not render the `#+RESULTS` blocks unless you manually delete the `#+RESULTS` tag from the output. This is tedious and error-prone, so it is best that you write the `README` in `org-mode` and export to `markdown`. That's what this task enables.

Also note that when `github` renders your `README.md`, it automatically adds a table of contents, so putting one in the `README.org` file is redundant. If you want to have one for your own purposes, just set the `:noexport` tag on it so it doesn't get put into the `README.md`

```ruby
rake docs:export
```


<a id="org4771f80"></a>

## Generate Yard Documents: \`rake docs:yard\`

This task generates a suitable `.yardopts` file if none exists and then generates `yard` documents into the gem's `doc` directory. It also makes sure that `yard` knows about your `README.md` file so user's of your gem will be able to get an overview of how to use your gem.

```ruby
rake docs:yard
```


<a id="orge03fb80"></a>

## Generate an Overview Comment for the Main gem File: \`rake docs:overview\`

Gem's typically gather into a central library file all the require's and other setup needed for the gem and the file is given the same name as the gem. For example, this gem uses the file `lib/gem_docs.rb` for this purpose. Since this `lib` directory is placed in the user's `LOADPATH`, a `require 'gem_docs'` or `require '<gemname>'` effectively initializes the gem.

By convention the comment immediately above the 'module' definition in your main library file is used by `yard` and `ri` as the overview for the gem.

```ruby
rake docs:overview
```

This extracts the "Introduction" section from `README.org` and makes it the overview comment in the gem's main library file. If it already exists, it replaces it with any newer version of the "Introduction" section, otherwise, it does not change the file.


<a id="orgfd976a7"></a>

# Confguration

The tasks defined by `gem_docs` should work out of the box with no configuration. They determine things like the name of the gem, your github user name, etc., by examining files in your repo. If this process gets things wrong, it should be considered a possible bug and reported.

Still, you can configure `gem_docs` with a configure block in your `Rakefile`. In this gem, for example, my `Rakefile` contains this:

```ruby
require "gem_docs"
GemDocs.install
GemDocs.configure do |c|
  c.overview_headings = ["Overview", "Usage"]
end
```

It tells the `docs:overview` task to use the "Overview" and "Usage" sections of this `README.org` as the overview comment. This is the most common reason you may want to add a configure block.

The following are the items that can be configured:

```ruby
GemDocs.configure do |c|
  c.overview_headings = ["Introduction"]
  c.headers =
    <<~HEADER
      #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
      #+PROPERTY: header-args:ruby+ :wrap example :session %n_session :eval yes
      #+PROPERTY: header-args:ruby+ :prologue "$:.unshift('./lib') unless $:.first == './lib'; require '%n'"
      #+PROPERTY: header-args:sh :exports code :eval no
      #+PROPERTY: header-args:bash :exports code :eval no
    HEADER
  c.repo_host = nil
  c.repo_name = nil
  c.repo_user = nil
  c.repo_branch = nil
  c.repo_workflow_dir = ".github/workflows"
  c.repo_workflow_name = nil
  c.badge =
    <<~BADGE
      #+BEGIN_EXPORT markdown
        [![CI](https://github.com/%u/%n/actions/workflows/%w/badge.svg?branch=%b)](https://github.com/%u/%n/actions/workflows/%w)
      #+END_EXPORT
    BADGE
end
```

```
false
```

The items that are set to `nil` here are populated at runtime by examining files in the gem's directory. In the strings for `headers` and `badge`, several markers are available as standins for these runtime values:

-   **%h:** the repo host, i.e., 'github.com', 'gitlab.com', etc.
-   **%u:** the repo's username on the host, such as 'ddoherty03' for me,
-   **%n:** the name of the gem, i.e., 'gem\_docs' for this gem,
-   **%b:** the branch of the repo, by default 'master',
-   **%r:** the directory where the repo root is located,
-   **%w:** the name of the workflow to be used in the badge, for example.


<a id="orge2657b7"></a>

# Development

After checking out the repo, run \`bin/setup\` to install dependencies. Then, run \`rake spec\` to run the tests. You can also run \`bin/console\` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run \`bundle exec rake install\`.


<a id="orga6c8dfa"></a>

# Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/ddoherty03/gem-docs>.


<a id="org56063ac"></a>

# License

The gem is available as open source under the terms of the [MIT License](<https://opensource.org/licenses/MIT>).
