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

# Updating Service Account Roles

By default, the new service accounts have the fewest permissions possible. To
perform some deployment task, you will need to assign the appropriate role,
which pre-defines the necessary permissions for common deployment types, e.g.
appengine-flexible-deployer, cloud-kubernetes-deployer, etc.

In the GCP Console:

 * GCP Console -> IAM & admin -> IAM
 * Edit the service account role
 * Look under Custom -> and choose the appropriate custom role

If you discover that a new role is necessary, or that an existing role needs
additional permissions, be certain to document your changes and inform the
team. Search the team drive for: "Conventions for M-Lab Release Automation".
