# Owin Framework Authorization UI
This NuGet package provides a user interface for managing groups, roles and permissions.
It also provides a user interface for searching for users and changing their group
membership.

The Html produced by the UI is fully decorated with semantic CSS class names, and is 
designed for the application developer to provide their own CSS rules, but the UI
also comes with its own default CSS for those that are not too picky.

The UI is written in Dart. The compiled JavaScript is embedded into the assembly so that
there is just one DLL to deploy to include this UI into any Owin Framework application.
