# Gradle-for-Delphi
Download dependencies from repositories, extract and create new jar, create JNI file, add to project.

This addon adds gradle functionality to the Delphi IDE. It downloads Libraries with all dependencies. It then extract all the classes from the jar files, and creates a new jar with these classes. This jar is run through Java2OP to create a JNI file. This JNI file and the jar file are added to the project.  

You have to download gradle from here https://gradle.org/releases/.
Install and add gradle to your path variable.

Install GetJars addon, and a new menuitem "Gradle" will appear under the Project menu.

Copy your java2op directory (e.g. C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\converters\java2op) to a directory with no spaces in the path (e.g. C:\Java2OP).

HOW TO USE:

Enter the path of your Java2OP directory in the "Java2OP location" box.
You have to edit the cache.txt in the Java2OP directory. if eks. you are downloading google play services, you have to remove those entries. 
You also have disable the build in jars in your projects libs entries. You should avoid using buildin libs, except for FMX.jar.

In the "Dependencies" box, enter the libs you want to download (Copy eks. from maven repository Gradle link). 
Try to keep the number of libraries down, as the jni file can grow very large.

In the "Additional (Local) Dependencies" enter any local libs that is needed for this job.

In the "Exclude when building JNI pas file" enter libs that is not to be processed by Java2OP. This can be a library that Java2OP cannot process (Hopefully you don't need to access it in your code). To reduce the size of the jni pas file, you can experiment with excluding libs.

In the "Job name" box enter a jobname. This will name the jar and JNI files.

Hit "Go"




