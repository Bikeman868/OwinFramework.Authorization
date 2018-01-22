# OwinFramework.Authorization

Provides an authorization mechanism for the Owin Framework

## Definition

Authorization is the business of figuring out what each 
identity within the system is permitted to do. This authorization
middleware requires an Identification mechanism to be installed
into the application. Any identification mechanism can be used.

## Features

This authorization middleware stores identity permissions in a
database using the Prius ORM. This ORM has plug-ins for all major
databases, but I only wrote SQL scripts to create the database in
MySQL so far. Translating this script into SQL Server or another
syntax is straightforward because the database is fairly simple.

This solution also contains an optional UI middleware. This middleware
is not required, but if you integrate it with your application then
it will fill a <div> element with a UI for managing permissions. The
UI is written in the Dart programming language which compiles into
JavaScript. This JavaScript and any image resources it references
are embedded into the assembly so that you only have to deploy a single 
DLL for the UI to work.

Before using the assets embedded in the UI assembly the assembly checks
for the existance of a file first and uses that in preference. This
means that you can customize the images and CSS for the authorization
UI by deploying your own versions of these fiels with your application.

## Data Model

This middleware defines the following entities:

### Permission

An action performed by your application that only some users are allowed 
to perform. You must write your application to check if the current user
has this permission before allowing the action.

Many OWIN framework components can be configured with the names of
permissions required. For example the static files middleware has a
configurable permission, and only users with that permission can
access the static fies.

Permissions can also be restricted to only give access to specific
resources, for example you can grant permission to update any users
profile, or restrict the permission to only certain users.
Your resources should be organized into a heirachy so that permissions
can be granted at the top of the heirachy can apply to everything
below it in the heirachy.

For example if you define a "view user information" permission you
might want to structure your user information so that for example
you can grant access to /user/*/profile (the profile information of
any user), or /user/123/profile (only grant access to the profile
of user 123) or /user/{my.username} (all of my own user information).

### Role

A collection of permissions that are frequently granted together. This
is called a role because the most common use case is that all staff with
a particular job title (role within the organization) need access to 
the same data and therefore have the same permissions.

An identity can have many roles. If any of these roles grants them access
to the protected resource then they are granted access.

### Group

This is a collection of identities that have exactly the same permissions.

If every identity needs a completely custom set of permissions then
you need to create a group for each identity and put only one identity
in each group. The more common use case is that there are collections
of identities with identical permissions and it makes it easier to
manage permissions at the group level.

### Identity

This authorization middleware must be used in conjunction with identification
middleware. The identification middleware is responsible for figuring out
who made the request. This middleware is responsible for figuring out
if the caller is allowed to make this request. The identity is the piece
that is shared between these two systems.

An identity can be a user identified though a login mechanism, a machine,
service, external third party integration, or anything else capable of
making a request to the service that is checking permissions.

Identities make claims about their identity and the Identification
middleware is responsible for checking these claims. For example a 
user might claim to have a first name of "John" and last name of "Doe"
with an email address of "john.doe@gov". The Identification middleware
might send an email to the email address with a link the user must click
to verrify their email address, or it might send SMS messages containing
codes, or require that the user present government issued ID in person
and have someone check it and confirm their claims.

As far as this Authorization middleware is concerned it trusts the 
Identification middleware to provide a unique identifier for the caller
who made the request, and to present a set of claims with validation status
for that identity. This middleware doesn't care how the caller was
identified, or how their claims wer validated.

In this Authorization middleware if you create a permission that says
you can read user information but limited to /user/{my.username} then
this middleware will only grant permission if the caller has a validated
"username" claim from the Identification middleware that matches the 
username of the user information that was requested.

