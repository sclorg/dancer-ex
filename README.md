Dancer Sample App on OpenShift
============================

This is a quickstart Dancer application for OpenShift v3.

The easiest way to install this application is to use the [OpenShift Instant Application](https://openshift.redhat.com/app/console/application_types).
If you'd like to install it manually, follow [these directions](https://github.com/openshift/dancer-ex/blob/master/README#manual-installation).  

OpenShift Considerations
------------------------
These are some special considerations you may need to keep in mind when running your application on OpenShift.

###Database
Your application is configured to use your OpenShift database in Production mode.  Because it addresses these databases based on
 url, you will need to change these if you want to use your application outside of OpenShift.

###Security
Since these quickstarts are shared code, we had to take special consideration to ensure that security related configuration variables was unique across applications. To accomplish this, we modified some of the configuration files (shown in the table below). Now instead of using the same default values, OpenShift can generate these values using the generate from logic defined within the instant application's template.

OpenShift stores these generated values in configuration files that only exist for your deployed application and not in your code anywhere. Each of them will be unique so initialize_secret(:a) will differ from initialize_secret(:b) but they will also be consistent, so any time your application uses them (even across reboots), you know they will be the same.

TLDR: OpenShift can generate and expose environment variables to our application automatically. Look at this quickstart for an example.

###Development mode
When you develop your Dancer application in OpenShift, you can also enable the 'development' environment by setting the environment variable [TODO].

Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.

###Manual Installation: 
1. Create an account at [https://www.openshift.com](https://www.openshift.com)  
*NOTE*: OpenShift Online currently is using V2.
2. Fork a copy of [dancer-ex](https://github.com/openshift/dancer-ex)
3. Clone your repository to your OpenShift server
3. Update the GitHub repository url in the instant app configuration to match your forked url 
2. Add a Perl application from the provided template
`osc process -f openshift/templates/dancer.json | create -f - `
3. Start the build  
`osc start-build dancer-app`
4. Watch your build progress  
`osc build-logs -f dancer-app-1`
5. Wait for frontend pods to start up (this can take a few minutes):  
`osc get pods`  
Sample output:  
>POD                  IP            CONTAINER(S)   IMAGE(S)                                                                                                             HOST                                            LABELS                                                                              STATUS       CREATED      MESSAGE
dancer-app-1-build                                                                                                                                                     ip-10-230-142-143.ec2.internal/10.230.142.143   build=dancer-app-1,buildconfig=dancer-app,name=dancer-app,template=dancer-example   Succeeded    15 minutes   
                                   sti-build      openshift/origin-sti-builder:v0.5.3                                                                                                                                                                                                                      Terminated   15 minutes   exit code 0
frontend-1-w6cef     172.17.0.50                                                                                                                                       ip-10-230-142-143.ec2.internal/10.230.142.143   deployment=frontend-1,deploymentconfig=frontend,name=frontend                       Running      3 minutes    
                                   dancer-app     172.30.221.178:5000/demo/origin-dancer-app@sha256:dd8452a64d8cf9ba36a461603306ae440b289f819c77dae1989c8980f3243f8e                                                                                                                                       Running      3 minutes    


6. Check the IP and port the frontend service is running on:  
`osc get services`  
Sample output:  
>NAME       LABELS                    SELECTOR        IP(S)            PORT(S)
frontend   template=dancer-example   name=frontend   172.30.223.197   8080/TCP

In this case, the IP for frontend is 172.30.223.197 and it is on port 8080.  
*Note*: you can also get this information from the web console.

###Manual Installation: With MySQL
1. Create an account at [https://www.openshift.com](https://www.openshift.com)  
*NOTE*: OpenShift Online currently is using V2.
2. Fork a copy of [dancer-ex](https://github.com/openshift/dancer-ex)
3. Clone your repository to your OpenShift server
3. Update the GitHub repository url in the instant app configuration to match your forked url 
2. Add a Perl application from the dancer-mysql template
`osc process -f openshift/templates/dancer-mysql.json | create -f - `
3. Start the build  
`osc start-build dancer-app`
4. Watch your build progress  
`osc build-logs -f dancer-app-1`  
5. Wait for frontend and database pods to be started (this can take a few minutes):  
`osc get pods`  
Sample output:  
>POD                  IP            CONTAINER(S)   IMAGE(S)                                                                                                             HOST                                            LABELS                                                                              STATUS       CREATED      MESSAGE
dancer-app-1-build                                                                                                                                                     ip-10-230-142-143.ec2.internal/10.230.142.143   build=dancer-app-1,buildconfig=dancer-app,name=dancer-app,template=dancer-example   Succeeded    15 minutes   
                                   sti-build      openshift/origin-sti-builder:v0.5.3                                                                                                                                                                                                                      Terminated   15 minutes   exit code 0
frontend-1-w6cef     172.17.0.50                                                                                                                                       ip-10-230-142-143.ec2.internal/10.230.142.143   deployment=frontend-1,deploymentconfig=frontend,name=frontend                       Running      3 minutes    
                                   dancer-app     172.30.221.178:5000/demo/origin-dancer-app@sha256:dd8452a64d8cf9ba36a461603306ae440b289f819c77dae1989c8980f3243f8e                                                                                                                                       Running      3 minutes    
mysql-1-4edf0        172.17.0.45                                                                                                                                       ip-10-230-142-143.ec2.internal/10.230.142.143   deployment=mysql-1,deploymentconfig=mysql,name=mysql                                Running      3 minutes   
                                   mysql          openshift/mysql-55-centos7:latest                                                                                                                                                                                                                        Running      3 minutes  

6. Check the IP and port the frontend service is running on:  
`osc get services`  
Sample output:  
>NAME       LABELS                    SELECTOR        IP(S)            PORT(S)
frontend   template=dancer-example   name=frontend   172.30.223.197   8080/TCP
mysql      template=mysql-template   name=mysql      172.30.139.179   3306/TCP
  
In this case, the IP for frontend is 172.30.223.197 and it is on port 8080.  
*Note*: you can also get this information from the web console.

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