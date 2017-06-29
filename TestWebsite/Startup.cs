using System;
using System.IO;
using System.Reflection;
using Ioc.Modules;
using Microsoft.Owin;
using Ninject;
using Owin;
using OwinFramework.Authorization;
using OwinFramework.Authorization.UI;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Middleware;
using TestWebsite;
using TestWebsite.Middleware;
using Urchin.Client.Sources;

[assembly: OwinStartup(typeof(Startup))]

namespace TestWebsite
{
    public class Startup
    {
        /// <summary>
        /// This is used to hold onto a reference to the Urchin file store. If the file
        /// store is disposed by the garbage collector then it will no longer notice
        /// changes in the configuration file.
        /// </summary>
        private static IDisposable _configurationFileSource;

        public void Configuration(IAppBuilder app)
        {
            //while (!System.Diagnostics.Debugger.IsAttached)
            //    System.Threading.Thread.Sleep(100);
            //System.Diagnostics.Debugger.Break();

            // By explicitly adding this assembly to the package locator, any IoC mappings
            // in this assembly will take priority over assemblies found through probing.
            // Also when the package locator probes for assemblies it only looks for DLLs
            // and not executables.
            var packageLocator = new PackageLocator()
                .ProbeBinFolderAssemblies()
                .Add(Assembly.GetExecutingAssembly());

            // Construct the Ninject IoC container and configure it using information from 
            // the package locator
            var ninject = new StandardKernel(new Ioc.Modules.Ninject.Module(packageLocator));

            // The prius factory needs Ninject to resolve interfaces to concrete types
            Prius.PriusFactory.Ninject = ninject;

            // Tell urchin to get its configuration from the config.json file in this project. Note that if
            // you edit this file whilst the application is running the changes will be applied without 
            // restarting the application.
            var hostingEnvironment = ninject.Get<IHostingEnvironment>();
            var configFile = new FileInfo(hostingEnvironment.MapPath("config.json"));
            _configurationFileSource = ninject.Get<FileSource>().Initialize(configFile, TimeSpan.FromSeconds(5));

            // Construct the configuration mechanism that is registered with IoC (Urchin)
            var config = ninject.Get<IConfiguration>();

            // Get the Owin Framework builder registered with IoC
            var builder = ninject.Get<IBuilder>();

            var apiPath = new PathString("/api");
            builder.Register(ninject.Get<IRouter>()
                .AddRoute("api", c => c.Request.Path.StartsWithSegments(apiPath))
                .AddRoute("default", c => true));

            // This is the authorization middleware we want to test
            builder.Register(ninject.Get<AuthorizationMiddleware>())
                .As("Authorization")
                .RunOnRoute("default");

            // This is the REST api that supportes the authorization Dart UI
            builder.Register(ninject.Get<AuthorizationApiMiddleware>())
                .As("Authorization API")
                .RunOnRoute("api");

            // Output caching just makes the web site more efficient by capturing the output from
            // downstream middleware and reusing it for the next request. Note that the Dart middleware
            // produces different results for the same URL and therefore can not use output caching
            builder.Register(ninject.Get<OwinFramework.OutputCache.OutputCacheMiddleware>())
                .As("Output cache")
                .ConfigureWith(config, "/middleware/outputCache")
                .RunAfter("Authorization Dart");
            
            // The Versioning middleware will add version numbers to static assets and
            // instruct the browser to cache them
            builder.Register(ninject.Get<OwinFramework.Versioning.VersioningMiddleware>())
                .As("Versioning")
                .ConfigureWith(config, "/middleware/versioning")
                .RunAfter<IOutputCache>();

            // The authorization user interface is written in the Dart programming language
            // This middleware will serve Dart files to browsers that natively support Dart
            // and compiled JavaScript to browsers that do not
            builder.Register(ninject.Get<OwinFramework.Dart.DartMiddleware>())
                .As("Authorization Dart")
                .ConfigureWith(config, "/middleware/authorizationUi")
                .RunOnRoute("default");

            // The Less middleware will compile LESS into CSS on the fly
            builder.Register(ninject.Get<OwinFramework.Less.LessMiddleware>())
                .As("LESS compiler")
                .ConfigureWith(config, "/middleware/less")
                .RunAfter("Authorization Dart")
                .RunOnRoute("default");

            // The static files middleware will allow requests to retrieve files of certian types
            // Configuration options limit the files that can be retrieved this way. The ConfigureWith
            // fluid method below specifies the location of this configuration in the config.json file
            builder.Register(ninject.Get<OwinFramework.StaticFiles.StaticFilesMiddleware>())
                .As("Static files")
                .ConfigureWith(config, "/middleware/staticFiles")
                .RunAfter("LESS compiler")
                .RunAfter("Authorization Dart")
                .RunOnRoute("default");

            // To make it easy to test Authorization, the user making the call is identified by
            // simply passing the user's identity in a query string parameter. Do not do this in a real
            // application.
            builder.Register(ninject.Get<QueryStringIdentification>())
                .As("Query string user identification")
                .RunOnRoute("default");

            // This middleware will check if the caller has certain permissions and return a page
            // with the results of the permissions check
            builder.Register(ninject.Get<CheckPermissionMiddleware>())
                .As("Check permissions")
                .RunOnRoute("default");

            // The default document middleware will rewrite a request for the root document to a page on the site
            builder.Register(ninject.Get<OwinFramework.DefaultDocument.DefaultDocumentMiddleware>())
                .As("Default document")
                .ConfigureWith(config, "/middleware/defaultDocument");

            // The documenter middleware will extract documentation from middleware that is 
            // self documenting. We need this to test that the authorization middleware self
            // documentation is working as expected
            builder.Register(ninject.Get<OwinFramework.Documenter.DocumenterMiddleware>())
                .As("Documenter")
                .RunOnRoute("default");

            // The exception reporter middleware will catch exceptions and produce diagnostic output
            builder.Register(ninject.Get<OwinFramework.ExceptionReporter.ExceptionReporterMiddleware>())
                .As("Exception reporter")
                .RunFirst();

            // Use the Owin Framework builder to add middleware to the Owin pipeline
            app.UseBuilder(builder);
        }
    }
}
