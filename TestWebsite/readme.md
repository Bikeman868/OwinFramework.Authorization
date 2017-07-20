# Developer notes

## Authorization UI

These notes are to remind myself how the Authorization UI works because it is a bit complicated.

This `TestWebsite` has a `Content\AuthorozationUI\web` folder that contains source code for a 
Dart application. This application is a user interface for managing permissions in the
authorization system.

You can test thie UI by fetching files from `Content\AuthorozationUI\web` using the static files
middleware. This `TestWebsite` also contains the Dart middleware which will direct Dart aware
browsers to the source files and other browsers to the compiled version. This is the best way
to debug the Dart code.

The compiled version can be updated by running the `build.cmd` file.

The `OwinFramework.Authorization.UI` projects reference the compiled version of the Dart application
and embed the files into the assembly. This middleware can serve these files directly out of the
resources embedded in the assembly so that when end users add this package to their project there
are no othr files to deploy to get the authorization UI working on their site.

This means that after updating the Dart code, you must re-compile it into JavaScript and then
recompile `OwinFramework.Authorization.UI` to embed the JavaScript into that assembly.
