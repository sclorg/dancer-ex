

<!-- toc -->

- [Dancer Sample App on OpenShift](#dancer-sample-app-on-openshift)
  * [OpenShift Considerations](#openshift-considerations)
    + [Security](#security)
    + [Development mode](#development-mode)
    + [Additional configuration](#additional-configuration)
    + [Installation:](#installation)
    + [Installation: With MySQL](#installation-with-mysql)
    + [Adding Webhooks and Making Code Changes](#adding-webhooks-and-making-code-changes)
    + [Enabling the Database sample](#enabling-the-database-sample)
    + [Compatibility](#compatibility)
    + [License](#license)

<!-- tocstop -->

Dancer Sample App on OpenShift
============================

This is a quickstart Dancer application for OpenShift v3 that you can use as a starting point to develop your own application and deploy it on an [OpenShift](https://github.com/openshift/origin) cluster.

If you'd like to install it, follow [these directions](https://github.com/sclorg/dancer-ex/blob/master/README.md#installation).  

The steps in this document assume that you have access to an OpenShift deployment that you can deploy applications on.

OpenShift Considerations
------------------------
These are some special considerations you may need to keep in mind when running your application on OpenShift.

### Security
Since these quickstarts are shared code, we had to take special consideration to ensure that security related configuration variables was unique across applications. To accomplish this, we modified some of the configuration files. Now instead of using the same default values, OpenShift can generate these values using the generate from logic defined within the instant application's template.

OpenShift stores these generated values in configuration files that only exist for your deployed application and not in your code anywhere. Each of them will be unique so initialize_secret(:a) will differ from initialize_secret(:b) but they will also be consistent, so any time your application uses them (even across reboots), you know they will be the same.

TLDR: OpenShift can generate and expose environment variables to your application automatically. Look at this quickstart for an example.

### Development mode
When you develop your Dancer application in OpenShift, you can also enable the 'development' environment by updating the value in <code>index.pl</code> like so <code>set environment => 'development';</code>.

Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.

### Additional configuration
The Perl container is set up so that Apache will load .conf files located within the <code>cfg</code> directory of the application's root.  This is useful if you are configuring your application with a database backend and would want to pass through your environment variables to mod_perl with <code>PerlPassEnv</code>.

### Installation: 
These steps assume your OpenShift deployment has the default set of ImageStreams defined.  Instructions for installing the default ImageStreams are available [here](https://docs.okd.io/latest/install_config/imagestreams_templates.html).    If you are defining the set of ImageStreams now, remember to pass in the proper cluster-admin credentials and to create the ImageStreams in the 'openshift' namespace.

1. Fork a copy of [dancer-ex](https://github.com/sclorg/dancer-ex)
2. Clone your repository to your development machine and cd to the repository directory
3. Add a Perl application from the provided template and specify the source url to be your forked repo  

		$ oc new-app openshift/templates/dancer.json -p SOURCE_REPOSITORY_URL=<your repository location>

4. Depending on the state of your system, and whether additional items need to be downloaded, it may take around a minute for your build to be started automatically.  If you do not want to wait, run

		$ oc start-build dancer-example

5. Once the build is running, watch your build progress  

		$ oc logs build/dancer-example-1

6. Wait for dancer-example pods to start up (this can take a few minutes):  

		$ oc get pods -w


	Sample output:  

		NAME                       READY     REASON    RESTARTS   AGE
		dancer-example-1-9d9vh    1/1       Running        0          41s
		dancer-example-1-build    0/1       ExitCode:0     0          4m


6. Check the IP and port the dancer-example service is running on:  

		$ oc get svc

	Sample output:  

		NAME              LABELS                          SELECTOR               IP(S)            PORT(S)
		dancer-example    template=dancer-example    name=dancer-example    172.30.225.109   8080/TCP

In this case, the IP for dancer-example is 172.30.225.109 and it is on port 8080.  
*Note*: you can also get this information from the web console.

### Installation: With MySQL
1. Follow the steps for the Manual Installation above for all but step 3, instead use step 2 below.  
  - Note: The output in steps 5-6 may also display information about your database.
2. Add a Perl application from the dancer-mysql template and specify the source url to be your forked repo  

		$ oc new-app openshift/templates/dancer-mysql.json -p SOURCE_REPOSITORY_URL=<your repository location>


### Adding Webhooks and Making Code Changes
Since OpenShift V3 does not provide a git repository out of the box, you can configure your github repository to make a webhook call whenever you push your code.

1. From the Web Console homepage, navigate to your project
2. Click on Browse > Builds
3. Click the link with your BuildConfig name
4. Click the Configuration tab
5. Click the "Copy to clipboard" icon to the right of the "GitHub webhook URL" field
6. Navigate to your repository on GitHub and click on repository settings > webhooks > Add webhook
7. Paste your webhook URL provided by OpenShift
8. Leave the defaults for the remaining fields - That's it!
9. After you save your webhook, if you refresh your settings page you can see the status of the ping that Github sent to OpenShift to verify it can reach the server.  

### Enabling the Database sample
To add REST and DB connectivity to this sample app, you can up date the application to launch using the code made available via this repository.  Edit 'app.psgi' to look like the following:

	#!/usr/bin/env perl
	use strict;
	use warnings;
	use FindBin;
	use lib "$FindBin::Bin/lib";
	use Dancer2;
	use inventory;
	#use default;

	inventory->to_app;
	#default->to_app;
	start;

It will also be necessary to update your application to talk to your database back-end. The inventory.pm file is configured to use DBI and $ENV in such a way that it will accept environment variables for your connection information that you pass to it. After creating a MySQL database service in your project, you can add the following environment variables to your deploymentConfig to ensure all your dancer-example pods have access to these environment variables. Note: the dancer-mysql.json template creates the DB service and environment variables for you. 

You will then need to rebuild the application.  This is done via either a `oc start-build` command, or through the web console, or a webhook trigger in github initiating a build after the code changes are pushed.

### Compatibility

This repository is compatible with Perl 5.20 and higher, excluding any alpha or beta versions.

### License
This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to [CC0](http://creativecommons.org/publicdomain/zero/1.0/).
