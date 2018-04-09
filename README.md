# travis
A support library for adding deployment automation in travis.

# Add submodule to a new repository

So travis can automatically checkout the travis submodule, use the `https`
address. Think of this as a read-only link to the travis repo.

From the root directory of the repo you're adding to travis:
```
git submodule add https://github.com/m-lab/travis.git
```

# Creating Service Accounts

Install the travis command line tool:

 * https://github.com/travis-ci/travis.rb#installation

From the top level repo (that contains travis as a submodule), run the command:

```
./travis/setup_service_accounts_for_travis.sh
```

Once complete, there should be three new service account environment variables
in the travis environment for your project. You can confirm this using the
travis CLI:

```
travis env list
```

If you require service account credentials in the testing project, pass an
additional parameter:

```
./travis/setup_service_accounts_for_travis.sh mlab-testing
```
