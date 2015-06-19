Dancer Sample App on OpenShift
============================

This is a quickstart Dancer application for OpenShift v3 that you can use as a starting point to develop your own application and deploy it on an [OpenShift](https://github.com/openshift/origin) cluster.

If you'd like to install it, follow [these directions](https://github.com/openshift/rails-ex/blob/master/README.md#installation).  

The steps in this assume that you have access to an OpenShift deployment; you must have an OpenShift deployment that you have access to in order to deploy this app.

OpenShift Considerations
------------------------
These are some special considerations you may need to keep in mind when running your application on OpenShift.

###Security
Since these quickstarts are shared code, we had to take special consideration to ensure that security related configuration variables was unique across applications. To accomplish this, we modified some of the configuration files. Now instead of using the same default values, OpenShift can generate these values using the generate from logic defined within the instant application's template.

OpenShift stores these generated values in configuration files that only exist for your deployed application and not in your code anywhere. Each of them will be unique so initialize_secret(:a) will differ from initialize_secret(:b) but they will also be consistent, so any time your application uses them (even across reboots), you know they will be the same.

TLDR: OpenShift can generate and expose environment variables to our application automatically. Look at this quickstart for an example.

###Development mode
When you develop your Dancer application in OpenShift, you can also enable the 'development' environment by updating the value in <code>index.pl</code> like so <code>set environment => 'development';</code>.

Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.

###Additional configuration
The Perl container is set up so that Apache will load .conf files located within the <code>cfg</code> directory of the application's root.  This is useful if you are configuring your application with a database backend and would want to pass through your environment variables to mod_perl with <code>PerlPassEnv</code>.

###Installation: 
These steps assume your OpenShift deployment has the default set of ImageStreams defined.  Instructions for installing the default ImageStreams are available [here](http://docs.openshift.org/latest/admin_guide/install/first_steps.html)

1. Fork a copy of [dancer-ex](https://github.com/openshift/dancer-ex)
2. Clone your repository to your development machine
3. Add a Perl application from the provided template and specify the source url to be your forked repo  

		$ oc process -f openshift/templates/dancer.json -v SOURCE_REPOSITORY_URL=<your repository location> | oc create -f - 

4. Watch your build progress  

		$ oc build-logs dancer-app-1

5. Wait for frontend pods to start up (this can take a few minutes):  

		$ oc get pods -w


	Sample output:  

		NAME                       READY     REASON    RESTARTS   AGE
		dancer-example-1-build     1/1       Running   0          4m
		dancer-frontend-1-deploy   1/1       Running   0          4s
		dancer-frontend-1-votfl    0/1       Pending   0          1s
		NAME                     READY     REASON       RESTARTS   AGE
		dancer-example-1-build   0/1       ExitCode:0   0          4m
		dancer-frontend-1-votfl   0/1       Running   0         6s
		dancer-frontend-1-deploy   0/1       ExitCode:0   0         14s
		dancer-frontend-1-votfl   1/1       Running   0         12s    


6. Check the IP and port the frontend service is running on:  

		$ oc get svc

	Sample output:  

		NAME              LABELS                          SELECTOR               IP(S)            PORT(S)
		dancer-frontend   template=dancer-mysql-example   name=dancer-frontend   172.30.174.142   8080/TCP

In this case, the IP for frontend is 172.30.174.142 and it is on port 8080.  
*Note*: you can also get this information from the web console.

###Installation: With MySQL
1. Follow the steps for the Manual Installation above for all but step 3, instead use step 2 below.  
  - Note: The output in steps 5-6 may also display information about your database.
2. Add a Perl application from the dancer-mysql template and specify the source url to be your forked repo  

		$ oc process -f openshift/templates/dancer-mysql.json -v SOURCE_REPOSITORY_URL=<your repository location> | oc create -f - 


###Adding Webhooks and Making Code Changes
Since OpenShift V3 does not provide a git repository out of the box, you can configure your github repository to make a webhook call whenever you push your code.

1. From the console navigate to your project  
2. Click on Browse > Builds  
3. From the view for your Build click on the link to display your GitHub webhook and copy the url.  
4. Navigate to your repository on GitHub and click on repository settings > webhooks  
5. Paste your copied webhook url provided by OpenShift - Thats it!  
6. After you save your webhook, if you refresh your settings page you can see the status of the ping that Github sent to OpenShift to verify it can reach the server.  

###License
This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to [CC0](http://creativecommons.org/publicdomain/zero/1.0/).