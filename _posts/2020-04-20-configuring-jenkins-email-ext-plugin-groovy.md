---
title: "Configuring the Jenkins email-ext plugin with Groovy"
tags: jenkins groovy
---

The default email notifications provided by [Jenkins][1] are a little
inflexible, but the [`email-ext` plugin][2] adds a whole host of configuration
options. [I use this to provide the build log in some sync jobs I have][3], but
I wanted to configure this via a script in Jenkins' `init.groovy.d` directory
to automate the configuration.

I've leaned [this article][4], [this Gist about setting up users][5] and [this
other Gist about configuring credentials][6] as I've done this before, but I
couldn't find anything which pulled together how you'd configure `email-ext`.
But I did come across [this now implemented issue which exposes the important
bits of what we'll need to configure][7], so a combination of the other
examples lead me to come up with the following:

```groovy
import jenkins.model.Jenkins

def inst = Jenkins.getInstance()
def emailExt = instance.getDescriptor(
  "hudson.plugins.emailext.ExtendedEmailPublisher")

emailExt.setSmtpAuth("username",
                     "password")
emailExt.setDefaultReplyTo("jenkins@example.com")
emailExt.setSmtpServer("smtp.example.com")
emailExt.setUseSsl(true)
emailExt.setSmtpPort("587")
emailExt.setCharset("utf-8")
emailExt.setDefaultRecipients("someone@example.com")

emailExt.save()
```

…which allows you to configure the basics of the account setup. This is loading
the current instant of `ExtendedEmailPublisherDescriptor`, so [any of the
setters in that class can be called this way][8].

[1]: https://jenkins.io
[2]: https://github.com/jenkinsci/email-ext-plugin
[3]: https://github.com/nickcharlton/jenkins-dsl
[4]: https://pghalliday.com/jenkins/groovy/sonar/chef/configuration/management/2014/09/21/some-useful-jenkins-groovy-scripts.html
[5]: https://gist.github.com/johnbuhay/c6213d3d12c8f848a385
[6]: https://gist.github.com/chrisvire/383a2c7b7cfb3f55df6a
[7]: https://issues.jenkins-ci.org/browse/JENKINS-39147
[8]: https://github.com/jenkinsci/email-ext-plugin/blob/master/src/main/java/hudson/plugins/emailext/ExtendedEmailPublisherDescriptor.java
