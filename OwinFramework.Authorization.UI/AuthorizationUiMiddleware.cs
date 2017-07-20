using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;

namespace OwinFramework.Authorization.UI
{
    public class AuthorizationUiMiddleware:
        IMiddleware<object>,
        IRoutingProcessor,
        ITraceable,
        IConfigurable
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }
        public Action<IOwinContext, Func<string>> Trace { get; set; }

        private readonly IHostingEnvironment _hostingEnvironment;

        private PathString _apiRootPath;
        private PathString _uiRootPath;

        public AuthorizationUiMiddleware(IHostingEnvironment hostingEnvironment)
        {
            _hostingEnvironment = hostingEnvironment;

            this.RunAfter<IAuthorization>(null, false);
            this.RunAfter<IIdentification>(null, false);

            ConfigurationChanged(new AuthorizationUiConfiguration());
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            if (context.Request.Path.StartsWithSegments(_uiRootPath))
            {

                if (!string.IsNullOrEmpty(_configuration.PermissionToCallApi))
                {
                    var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                    var upstreamAuthorization = context.GetFeature<IUpstreamAuthorization>();

                    if (upstreamIdentification != null)
                        upstreamIdentification.AllowAnonymous = false;

                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToCallApi);
                }
            }
            else
            {
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
            }

            return next();
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            PathString remaining;
            if (!context.Request.Path.StartsWithSegments(_uiRootPath, out remaining) || 
                !remaining.HasValue)
            {
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
                return next();
            }

            var resource = GetResource(remaining.Value);
            if (resource == null)
                throw new HttpException((int)HttpStatusCode.NotFound, "No resource '" + remaining.Value + "'");

            context.Response.ContentType = resource.MimeType;
            return context.Response.WriteAsync(resource.Content);
        }

        #region IConfigurable

        private IDisposable _configurationRegistration;
        private AuthorizationUiConfiguration _configuration = new AuthorizationUiConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
            _configurationRegistration = configuration.Register(
                path,
                ConfigurationChanged,
                new AuthorizationUiConfiguration());
        }

        private void ConfigurationChanged(AuthorizationUiConfiguration configuration)
        {
            _configuration = configuration;

            Func<string, PathString> normalizePath = p =>
            {
                if (string.IsNullOrEmpty(p)) return new PathString();

                p = p.ToLower();
                if (!p.StartsWith("/")) p = "/" + p;
                if (p.Length == 1) return new PathString("/");

                if (p.EndsWith("/")) p = p.Substring(0, p.Length - 1);
                return new PathString(p);
            };

            Func<PathString, string, PathString> filePath = (p, f) =>
            {
                if (!p.HasValue || string.IsNullOrEmpty(f))
                    return new PathString();

                if (f.StartsWith("/")) f = f.Substring(1);

                return p.Value == "/"
                    ? new PathString("/" + f)
                    : new PathString(p.Value + "/" + f);
            };

            _apiRootPath = normalizePath(configuration.ApiRootUrl);
            _uiRootPath = normalizePath(configuration.UiRootUrl);

            lock (_resources) _resources.Clear();
        }

        #endregion

        #region Embedded resources

        private EmbeddedResource GetResource(string filename)
        {
            filename = filename.ToLower();

            EmbeddedResource resource;
            lock(_resources)
                if (_resources.TryGetValue(filename, out resource))
                    return resource;

            resource = new EmbeddedResource
            {
                FileName = filename
            };

            if (filename.EndsWith(".gif"))
                resource.MimeType = "image/gif";
            else if (filename.EndsWith(".ico"))
                resource.MimeType = "image/ico";
            else if (filename.EndsWith(".js"))
                resource.MimeType = "application/javascript";
            else if (filename.EndsWith(".html"))
                resource.MimeType = "text/html";
            else if (filename.EndsWith(".css"))
            {
                resource.MimeType = "text/css";
                filename = Path.ChangeExtension(filename, ".less");
            }

            var physicalFile = new FileInfo(_hostingEnvironment.MapPath(_configuration.AssetsPath + filename));
            if (physicalFile.Exists)
            {
                if (resource.MimeType.StartsWith("image/"))
                {
                    resource.Content = new byte[physicalFile.Length];
                    using (var stream = physicalFile.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
                    {
                        ReadBinaryResource((int)physicalFile.Length, stream, resource);
                    }
                }
                else
                {
                    using (var streamReader = physicalFile.OpenText())
                    {
                        ReadTextResource(filename, streamReader, resource);
                    }
                }
            }
            else
            {
                var resourceStream = FindEmbeddedResource(filename);
                if (resourceStream != null)
                {
                    using (resourceStream)
                    {
                        if (resource.MimeType.StartsWith("image/"))
                        {
                            ReadBinaryResource((int)resourceStream.Length, resourceStream, resource);
                        }
                        else
                        {
                            using (var reader = new StreamReader(resourceStream, Encoding.UTF8))
                            {
                                ReadTextResource(filename, reader, resource);
                            }
                        }
                    }
                }
            }

            lock (_resources)
                _resources[filename] = resource;

            return resource;
        }

        private void ReadTextResource(string filename, StreamReader reader, EmbeddedResource resource)
        {
            var text = reader.ReadToEnd();
            text = TransformTextResource(filename, text);
            resource.Content = Encoding.UTF8.GetBytes(text);
        }

        private void ReadBinaryResource(int length, Stream stream, EmbeddedResource resource)
        {
            resource.Content = new byte[length];
            var offset = 0;
            while (true)
            {
                var bytesRead = stream.Read(resource.Content, offset, length - offset);
                if (bytesRead == 0) return;
                offset += bytesRead;
            }
        }

        private string TransformTextResource(string filename, string content)
        {
            if (filename.EndsWith(".less"))
            {
                return dotless.Core.Less.Parse(
                    content,
                    new dotless.Core.configuration.DotlessConfiguration
                    {
                        MinifyOutput = true
                    });
            }

            if (filename.EndsWith(".dart.js") || filename.EndsWith(".html"))
            {
                return content
                    .Replace("{_api-url_}", _apiRootPath.Value)
                    .Replace("{_ui-url_}", _uiRootPath.Value)
                    .Replace("{_images-url_}", _uiRootPath.Value)
                    .Replace("{_v_}", "");
            }

            return content;
        }

        private Stream FindEmbeddedResource(string filename)
        {
            var resources = Assembly.GetExecutingAssembly()
                .GetManifestResourceNames();

            filename = filename.Replace("/", ".");

            var scriptResourceName = resources.FirstOrDefault(n => n.ToLower().Contains(filename));

            if (scriptResourceName == null)
                return null;

            return Assembly.GetExecutingAssembly().GetManifestResourceStream(scriptResourceName);
        }

        private class EmbeddedResource
        {
            public string FileName;
            public byte[] Content;
            public string MimeType;
        }

        private readonly IDictionary<string, EmbeddedResource> _resources = new Dictionary<string, EmbeddedResource>(StringComparer.InvariantCultureIgnoreCase);

        #endregion
    }
}
