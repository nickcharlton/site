---
title: "Setting Jenkins Credentials with Groovy"
published: 2020-05-08 17-37-16 +01:00
tags: jenkins groovy
---

I've been building up a nice pattern for bootstrapping Jenkins' secrets
through `init.groovy.d`, storing the secrets themselves inside configuration
management. So far, this has been the simplest way to get a working
configuration without additional moving parts beyond Jenkins and a
configuration management tool.

The [Jenkins Credentials plugin][1] supports a few different secret types:
"secret text" (which can be used as an environment variable), username &
password, files from the file system and a few others. We can handle SSH private
keys using the [SSH Credentials plugin][2]. These can be made available
globally (i.e.: across multiple build nodes), or just on specific build nodes
but here we're just going to treat them as global.

## As `init.groovy.d` scripts

I've used a few sources to understand how to do this in the past, especially
[this Gist][3]. But I wanted to do this incrementally and be cautious on which
dependencies were being imported. So, here's how to implement each:

### Secret Text

{% raw %}
```groovy
#!/usr/bin/env groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList(
  "com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

secretText = new StringCredentialsImpl(
  CredentialsScope.GLOBAL,
  "SECRET_NAME",
  "SECRET_DESCRIPTION",
  Secret.fromString("SECRET_TEXT")
)

store.addCredentials(domain, secretText)
```
{% endraw %}

### Username & Password

{% raw %}
```groovy
#!/usr/bin/env groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList(
  "com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "SECRET_NAME",
  "SECRET_DESCRIPTION",
  "USERNAME",
  "PASSWORD"
)

store.addCredentials(domain, usernameAndPassword)
```
{% endraw %}

[The source for the implementation contains some additional options.][4]

### SSH Private Key

{% raw %}
```groovy
#!/usr/bin/env groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey
import com.cloudbees.plugins.credentials.CredentialsScope

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList(
  "com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

privateKey = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(
  '''
  PRIVATE_KEY_TEXT
  '''
)

sshKey = new BasicSSHUserPrivateKey(
  CredentialsScope.GLOBAL,
  "SECRET_TEXT",
  "PRIVATE_KEY_USERNAME",
  privateKey,
  "PRIVATE_KEY_PASSPHRASE",
  "SECRET_DESCRIPTION"
)

store.addCredentials(domain, sshKey)
```
{% endraw %}

This was more difficult to figure out than the others, [with the implementation
of `BasicSSHUserPrivateKey.java` invaluable][5].

It supports multiple different types of SSH keys: entering directly (what we're
doing here) but also reading off the disk. [We need to use `'''` to have a
multi-line string][6] as the private key will span a few lines. You'll need
the [`ssh-credentials` plugin installed][2], too.

## Configuring with Ansible

I'm using [Ansible][7] (with secrets stored in [Ansible Vault][8]), based
around [Jeff Geerling's Ansible role for Jenkins][9], but this pattern could
be replicated elsewhere.

Ansible Vault arranges secrets by encrypting variables which are
accessible when playbooks are run. My original idea was to have a single
variable name which when written would reflect on the type you set, for example:

```yaml
---
jenkins_global_secrets:
  - name: EXAMPLE_SECRET_TEXT
    description: An example secret text value
    value: a_very_important_secret
    type: :secret_text
```

But this caused quite a bit complexity when trying to work out where the logic
should be. To bridge the secrets from Ansible Vault to the provisioned machine,
they're written out [from a _template_ of the Groovy file][10] and so splitting
some of the logic between the template stage (which Ansible does) and the
Groovy file (which is executed on runtime) felt misguided.

A much nicer approach seemed to be to use many top level variables, and instead
you end up with this:

```yaml
---
jenkins_secret_text_credentials:
  - name: EXAMPLE_SECRET_TEXT
    description: An example secret text value
    secret: a_very_important_secret
```

[Which is very similar to how the Jenkins Chef cookbook solves this
problem][11]. From here, we can use this in a template like this
(`configure_jenkins_credentials.groovy.j2`):

{% raw %}
```groovy
#!/usr/bin/env groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList(
  "com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

{% for secret in jenkins_global_secrets %}
secretText = new StringCredentialsImpl(
  CredentialsScope.GLOBAL,
  "{{ secret['name'] }}",
  "{{ secret['description'] }}",
  Secret.fromString("{{ secret['text'] }}")
)

store.addCredentials(domain, secretText)
{% endfor %}
```
{% endraw %}

In Ansible, this would then be written to the right place with something like
this:

{% raw %}
```yaml
- name: Place the Jenkins Credentials Groovy script
  template:
    src: "configure_jenkins_credentials.groovy.j2"
    dest: "{{ jenkins_home }}/init.groovy.d/configure_jenkins_credentials.groovy"
```
{% endraw %}

With multiple top-level variables like this, the final result ends up being:

{% raw %}
```groovy
#!/usr/bin/env groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope
import hudson.util.Secret
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList(
  "com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

{% for credential in jenkins_secret_text_credentials %}
secretText = new StringCredentialsImpl(
  CredentialsScope.GLOBAL,
  "{{ credential['name'] }}",
  "{{ credential['description'] }}",
  Secret.fromString("{{ credential['text'] }}")
)

store.addCredentials(domain, secretText)
{% endfor %}

{% for credential in jenkins_ssh_credentials %}
privateKey = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(
  '''
  {{ credential['private_key'] }}
  '''
)

sshKey = new BasicSSHUserPrivateKey(CredentialsScope.GLOBAL,
                                    "{{ credential['name'] }}",
                                    "{{ credential['username'] }}",
                                    privateKey,
                                    "{{ credential['passphrase'] }}",
                                    "{{ credential['description'] }}"
)

store.addCredentials(domain, sshKey)
{% endfor %}

{% for credential in jenkins_username_password_credentials %}
usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "{{ credential['name'] }}",
  "{{ credential['description'] }}",
  "{{ credential['username'] }}",
  "{{ credential['password'] }}"
)

store.addCredentials(domain, usernameAndPassword)
{% endfor %}
```
{% endraw %}

[1]: https://plugins.jenkins.io/credentials/
[2]: https://plugins.jenkins.io/ssh-credentials
[3]: https://gist.github.com/chrisvire/383a2c7b7cfb3f55df6a
[4]: https://github.com/jenkinsci/credentials-plugin/blob/master/src/main/java/com/cloudbees/plugins/credentials/impl/UsernamePasswordCredentialsImpl.java
[5]: https://github.com/jenkinsci/ssh-credentials-plugin/blob/master/src/main/java/com/cloudbees/jenkins/plugins/sshcredentials/impl/BasicSSHUserPrivateKey.java#L108
[6]: http://groovy-lang.org/syntax.html#_triple_single_quoted_string
[7]: https://docs.ansible.com/ansible/latest/index.html
[8]: https://docs.ansible.com/ansible/latest/user_guide/vault.html
[9]: https://github.com/geerlingguy/ansible-role-jenkins
[10]: https://docs.ansible.com/ansible/latest/modules/template_module.html#examples
[11]: https://github.com/chef-cookbooks/jenkins#jenkins_credentials
