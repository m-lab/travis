# travis
A support library for adding deployment automation in travis.


## Encrypting files for travis

### Recovering if encryption keys are overwritten

Encryption keys may be overwritten by invoking `travis encrypt-file` more than
once for the same repository.

In the event that the encryption keys are lost, there are a few
steps that have to be taken to restore functionality.

 1. If the SA keys are available, skip to step 4.
 2. Create new service accounts or new keys for existing account, for
    mlab-sandbox and mlab-staging, downloading the json key files.
 3. Update GCS ACLs, e.g.
    ```
    gsutil acl ch -R -u \
       legacy-rpm-writer@mlab-sandbox.iam.gserviceaccount.com:WRITE \
       gs://legacy-rpms-mlab-sandbox
    ```
 4. Tar the SA keys:
    tar cf service-accounts.tar legacy-rpm-writer.mlab*
 5. Encrypt the tar file:
    `travis encrypt-file -f -p service-accounts.tar --repo m-lab/<repo-name>`
    Optionally, if you want to provide the keys for some other repos,
    copy the key and iv values into a command like:
    travis encrypt-file -f -p service-accounts.tar --key \
      AAA151324478927bbbbbbbbbcccccccccccccdddddddddd53223551235324324 \
      --iv 632451671306d1842843a792250ce707 --repo gfr10598/ndt-support
 6. Copy the keys printed when you encrypted the tar file,
    and paste them in place of the three occurances in the script
    commands below.
 7. Copy the encrypted tar file to the travis directory (where
    this script is located).
 8. Commit to an appropriate branch, generate PR, and send for review.
