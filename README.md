# Gradle-for-Delphi
Download dependencies from repositories, extract and create new jar, create JNI file, add to project.

This addon adds gradle functionality to the Delphi IDE. It downloads Libraries with all dependencies. It then extract all the classes from the jar files, and creates a new jar with these classes. This jar file is added to the project.  

You have to download gradle 8.11.1 from here https://gradle.org/releases/.
Install and add gradle to your path variable.

You need to have JEDI JCL installed.

Install GetJars addon, and a new menuitem "Gradle" will appear under the Project menu.

Copy your java2op directory (e.g. C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\converters\java2op) to a directory with no spaces in the path (e.g. C:\Java2OP).

Enter the path of your Java2OP/JavaImport/JDK/Build Tools directories in Mainmenu->Settings.
Enter path to JDK that is to be used by Gradle when it processes resources. The JDK version should be version 17.

HOW TO USE:

You have to edit the cache.txt in the Java2OP/JavaImport directory. if e.g. you are downloading google play services, you have to remove those entries. 
You also have to disable the build in jars in your projects libs entries. You should avoid using buildin libs, except for FMX.jar.

Add jobs that contain logical units of work. Do not put everything in one job, as the resulting jni file can grow very large, and Delphi cannot compile JNI with more than a 100000-120000 lines.

In the "Job name" box enter a jobname. This will name the JNI file.

In the "Dependencies" box, enter the libs you want to download (Copy eks. from maven repository Gradle link). The command has to be in one line 
(e.g ('com.azure:azure-identity:1.2.5') {exclude group: 'com.azure', module: 'azure-core-http-netty'}). "Implementation" and "Compile" prefix will be removed. 

In the "Additional (Local) Dependencies" enter any local libs that is needed for this job.
You have to add any dependencies to these libs in the dependencies box.

In the "Exclude when building JNI pas file" enter libs/directories/class's that are not to be processed by Java2OP. This can be content that Java2OP cannot process (Hopefully you don't need to access it in your code).

In the "Exclude from final jar" enter libs/directories/class's that are not to be included in the final jar file. It can be test or compile time dependensies.

Add repositories needed for your project in "Repositories".

Create JNI file by clicking "Create JNI pas file".

When you have finished coding against the JNI file, shrink it with "Shrink JNI Files" addon, which can be downloaded from here https://github.com/helgovic/Delphi-shrink-JNI-files.

When you are ready to compile your app, compile project jar by clicking "Compile Project Jar".

RESOURCES

Processing of resouces from libraries will merge resources from your project (Place your own resources in YOURPROJECT\Res directory), with resouces from dependencies, and place these in folder YOURPROJECT\MergedRes. Resouces from YOURPROJECT\MergedRes will be added to your Deployment files. A R.jar containing R.class'es for the libraries will be generated and added to project. Remember, if you make updates to your own app's resources, you need to run "Compile Project Jar". 

EXCLUSION PARAMETERS

You can enter three types of parameters:
1. Not prefixed (e.g. guana). This denotes jars/aars where string is contained in the file name. (Not case sensitive).
2. Prefixed with / (e.g. /android\support\v4). Denotes a directory of classes, that are to be excluded. (Case sensitive).
3. Prefixed with ¤ (e. g. ¤com\google\android\exoplayer2\source\CompositeMediaSource$ForwardingEventListener.class). Denotes single class that is to be excluded. (Case sensitive).
4. Comments (//) and blank lines can be entered.


